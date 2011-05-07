require 'rubygems'

require 'thread'
require 'weakref'

module ActiveSupport
  # WeakReference is a class to represent a reference to an object that is not seen by
  # the tracing phase of the garbage collector.  This allows the referenced
  # object to be garbage collected as if nothing is referring to it.
  #
  # This class provides several compatibility and performance benefits over using
  # the WeakRef implementation that comes with Ruby and is compatible with Jruby.
  #
  # Usage:
  #
  #   foo = Object.new
  #   ref = ActiveSupport::WeakReference.new(foo)
  #   ref.alive?			# should be true
  #   ref.object			# should be foo
  #   ObjectSpace.garbage_collect
  #   ref.alive?			# should be false
  #   ref.object			# should be nil
  class WeakReference
    # The object id of the object being referenced.
    attr_reader :referenced_object_id
    
    class << self
      # Create a new WeakReference. The actual implementation class will be
      # optimized for the runtime is being used. If the default implementation
      # isn't appropriate, it can be changed by setting a different one.
      def new(obj)
        ref = implementation.allocate
        ref.instance_variable_set(:@referenced_object_id, obj.__id__)
        ref.send(:initialize, obj)
        ref
      end

      # Get the implementation class for weak references.
      def implementation
        @implementation
      end

      # Set the implementation class for weak references.
      def implementation=(klass)
        @implementation = klass
      end
    end

    # Get the referenced object. If the object has been reclaimed by the
    # garbage collector, then this will return nil.
    def object
      raise NotImplementedError
    end

    def inspect
      obj = object
      "<##{self.class.name}: #{obj ? obj.inspect : "##{referenced_object_id} (not accessible)"}>"
    end

    # This is a pure ruby implementation of a weak reference. It is much more
    # efficient than the bundled WeakRef implementation because it does not
    # subclass Delegator which is very heavy to instantiate and utilizes a
    # fair amount of memory.
    #
    # This implementation cannot be used by Jruby if ObjectSpace has been
    # disabled.
    class StandardImpl < WeakReference
      # Map of references to the object_id's they refer to.
      @@referenced_object_ids = {}

      # Map of object_ids to references to them.
      @@object_id_references = {}

      @@mutex = Mutex.new

      # Finalizer that cleans up weak references when an object is destroyed.
      @@object_finalizer = lambda do |object_id|
        @@mutex.synchronize do
          reference_ids = @@object_id_references[object_id]
          if reference_ids
        	  reference_ids.each do |reference_object_id|
        	    @@referenced_object_ids.delete(reference_object_id)
        	  end
        	  @@object_id_references.delete(object_id)
      	  end
        end
      end

      # Finalizer that cleans up weak references when references are destroyed.
      @@reference_finalizer = lambda do |object_id|
        @@mutex.synchronize do
          referenced_id = @@referenced_object_ids.delete(object_id)
          if referenced_id
            obj = ObjectSpace._id2ref(referenced_object_id) rescue nil
            if obj
              backreferences = obj.instance_variable_get(:@__weak_backreferences__) if obj.instance_variable_defined?(:@__weak_backreferences__)
              if backreferences
                backreferences.delete(object_id)
                obj.remove_instance_variable(:@__weak_backreferences__) if backreferences.empty?
              end
            end
            references = @@object_id_references[referenced_id]
            if references
              references.delete(object_id)
          	  @@object_id_references.delete(referenced_id) if references.empty?
        	  end
      	  end
        end
      end

      # Create a new weak reference to an object. The existence of the weak reference
      # will not prevent the garbage collector from reclaiming the referenced object.
      def initialize(obj)
        ObjectSpace.define_finalizer(obj, @@object_finalizer)
        ObjectSpace.define_finalizer(self, @@reference_finalizer)
        @@mutex.synchronize do
          @@referenced_object_ids[self.__id__] = obj.__id__
          add_backreference(obj)
          references = @@object_id_references[obj.__id__]
          unless references
            references = []
            @@object_id_references[obj.__id__] = references
          end
          references.push(self.__id__)
        end
      end

      # Get the reference object. If the object has already been garbage collected,
      # then this method will return nil.
      def object
        obj = nil
        begin
          if referenced_object_id == @@referenced_object_ids[self.object_id]
            obj = ObjectSpace._id2ref(referenced_object_id)
            obj = nil unless verify_backreferences(obj)
          end
        rescue RangeError
          # Object has been garbage collected.
        end
        obj
      end

      private

        def add_backreference(obj)
          backreferences = obj.instance_variable_get(:@__weak_backreferences__) if obj.instance_variable_defined?(:@__weak_backreferences__)
          unless backreferences
            backreferences = []
            obj.instance_variable_set(:@__weak_backreferences__, backreferences)
          end
          backreferences << object_id
        end

        def verify_backreferences(obj)
          backreferences = obj.instance_variable_get(:@__weak_backreferences__) if obj.instance_variable_defined?(:@__weak_backreferences__)
          backreferences && backreferences.include?(object_id)
        end
    end

    # This implementation of a weak reference utilizes the weakling library which will
    # use native Java weak references when running under Jruby. If the weakling gem
    # has been required this will automatically be used.
    class WeaklingImpl < WeakReference
      def initialize(obj)
        @ref = ::Weakling::WeakRef.new(obj)
      end

      def object
        @ref.get
      rescue RefError
        nil
      end
    end

    # This implementation of a weak reference simply wraps the standard WeakRef implementation
    # that comes with Ruby. It is used as a fallback for Jruby if case the weakling gem
    # is not available.
    class WeakRefImpl < WeakReference
      def initialize(obj)
        @ref = ::WeakRef.new(obj)
      end

      def object
        @ref.__getobj__
      rescue => e
        # Jruby implementation uses RefError while MRI uses WeakRef::RefError
        if (defined?(RefError) && e.is_a?(RefError)) || (defined?(::WeakRef::RefError) && e.is_a?(::WeakRef::RefError))
          nil
        else
          raise e
        end
      end
    end

    # This implementation can be used for testing. It implements the proper interface,
    # but allows for mimicking garbage collection on demand.
    class TestImpl < WeakReference
      @@object_list = {}

      def initialize(obj)
        @object = obj
        @@object_list[obj.__id__] = true
        ObjectSpace.define_finalizer(self, lambda{@@object_list.delete(obj.__id__)})
      end

      def object
        if @@object_list.include?(@object.__id__)
          @object
        else
          @object = nil
        end
      end

      # Simulate garbage collection of the objects passed in as arguments. If no objects
      # are specified, all objects will be reclaimed.
      def self.gc(*objects)
        if objects.empty?
          @@object_list = {}
        else
          objects.each{|obj| @@object_list.delete(obj.__id__)}
        end
      end
    end

    if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
      # If using Jruby set the implementation depending on whether or not the weakling gem is installed.
      begin
        require 'weakling'
        self.implementation = WeaklingImpl
      rescue LoadError
        self.implementation = WeakRefImpl
      end
    elsif defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
      # If using Rubinius set the implementation to use WeakRef since it is very efficient.
      self.implementation = WeakRefImpl
    else
      self.implementation = StandardImpl
    end
  end
end

class WeakRefTest
  def self.test_object_ids
    puts "Testing if object id's can be reused..."
    i = 0
    id_to_class = {}

    loop do
      i += 1
      obj = Object.new

      if id_to_class.key?(obj.object_id)
        puts "\nFAIL: found a reused object id after #{i} iterations"
        break
      end

      id_to_class[obj.object_id] = obj.class
      if i % 50000 == 0
        STDOUT.write('.')
        STDOUT.flush
      end
      
      if i == 100000
        puts "\nSUCCESS: no object id's were reused after 100,000 iterations"
        break
      end
    end
  end

  def self.test_weak_ref_object_ids
    puts "Testing if object id's can be reused by WeakRef..."
    i = 0
    n = 0
    id_to_ref = {}

    loop do
      i += 1
      obj = Object.new

      if id_to_ref.key?(obj.object_id)
        n += 1
        ref = id_to_ref[obj.object_id]
        if ref.weakref_alive?
          puts "\nFAIL: found a reused object id after #{i} iterations"
          break
        end
      end

      id_to_ref[obj.object_id] = WeakRef.new(obj)
      if i % 2500 == 0
        STDOUT.write('.')
        STDOUT.flush
      end
      
      if i == 100000
        puts "\nSUCCESS: even with #{n} object id's being reused in 100,000 iterations"
        break
      end
    end
  end
  
  def self.test_weak_reference_object_ids
    puts "WeakReference implementation is #{ActiveSupport::WeakReference.implementation.name}"
    i = 0
    n = 0
    id_to_ref = {}

    loop do
      i += 1
      obj = Object.new

      if id_to_ref.key?(obj.object_id)
        n += 1
        ref = id_to_ref[obj.object_id]
        if ref.object
          puts "\nFAIL: found a reused object id after #{i} iterations"
          break
        end
      end

      id_to_ref[obj.object_id] = ActiveSupport::WeakReference.new(obj)
      if i % 5000 == 0
        STDOUT.write('.')
        STDOUT.flush
      end
      
      if i == 100000
        puts "\nSUCCESS: even with #{n} object id's being reused in 100,000 iterations"
        break
      end
    end
  end
end

if $0 == __FILE__
  if ARGV.empty?
    STDERR.puts "Usage: ruby weakref_test.rb object|weakref|weakreference"
  else
    ARGV.each do |arg|
      case arg
      when "object"
        t = Time.now
        1000.times{Object.new}
        puts "It takes #{Time.now - t} seconds to allocate 1000 Objects"
        WeakRefTest.test_object_ids
      when "weakref"
        t = Time.now
        1000.times{WeakRef.new(Object.new)}
        puts "It takes #{Time.now - t} seconds to allocate 1000 WeakRefs"
        WeakRefTest.test_weak_ref_object_ids
      when "weakreference"
        t = Time.now
        1000.times{ActiveSupport::WeakReference.new(Object.new)}
        puts "It takes #{Time.now - t} seconds to allocate 1000 ActiveSupport::WeakReferences"
        puts "Testing if object_ids can be reused by ActiveSupport::WeakReference..."
        WeakRefTest.test_weak_reference_object_ids
      end
    end
  end
end