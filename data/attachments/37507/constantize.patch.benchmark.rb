require 'benchmark'

class String
  def blank?; empty? || strip.empty?; end
end

def new_constantize(camel_cased_word)
  list = camel_cased_word.split('::')
  list.shift if list.first.blank?
  obj = Object
  list.each do |x|
    obj = obj.const_defined?(x) ? obj.const_get(x) : obj.const_missing(x)
  end
  obj
end

def old_constantize(camel_cased_word)
  unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
    raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
  end

  Object.module_eval("::#{$1}", __FILE__, __LINE__)
end

puts "\n'String'"

Benchmark.bm do |x|
  x.report('const') { new_constantize('String') }
  x.report('eval') { old_constantize('String') }
end

module A; module B; module C; module D; module E; module F; end; end; end; end; end; end

puts "\n'A::B'"

Benchmark.bm do |x|
  x.report('const') { new_constantize('A::B') }
  x.report('eval') { old_constantize('A::B') }
end

puts "\n'A::B::C'"

Benchmark.bm do |x|
  x.report('const') { new_constantize('A::B::C') }
  x.report('eval') { old_constantize('A::B::C') }
end