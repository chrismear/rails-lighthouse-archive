module ActiveRecord
  module Batches # :nodoc:
    def self.included(base)
      base.extend(ClassMethods)
    end

    # When processing large numbers of records, it's often a good idea to do so in batches to prevent memory ballooning.
    module ClassMethods
      # Yields each record that was found by the find +options+. The find is performed by find_in_batches
      # with a batch size of 1000 (or as specified by the +batch_size+ option).
      #
      # Example:
      #
      #   Person.find_each(:conditions => "age > 21") do |person|
      #     person.party_all_night!
      #   end
      #
      # Note: This method is only intended to use for batch processing of large amounts of records that wouldn't fit in
      # memory all at once. If you just need to loop over less than 1000 records, it's probably better just to use the
      # regular find methods.
      def find_each(options = {})
        find_in_batches(options) do |records|
          records.each { |record| yield record }
        end

        self
      end

      # Yields each batch of records that was found by the find +options+ as an array. The size of each batch is
      # set by the +batch_size+ option; the default is 1000.
      #
      # You can control the starting point for the batch processing by supplying the +start+ option. This is especially
      # useful if you want multiple workers dealing with the same processing queue. You can make worker 1 handle all the
      # records between id 0 and 10,000 and worker 2 handle from 10,000 and beyond (by setting the +start+ option on that
      # worker).
      #
      # It's not possible to set the order. That is automatically set to ascending on the primary key ("id ASC") 
      # to make the batch ordering work.
      #
      # Example:
      #
      #   Person.find_in_batches(:conditions => "age > 21") do |group|
      #     sleep(50) # Make sure it doesn't get too crowded in there!
      #     group.each { |person| person.party_all_night! }
      #   end
      #
      # Note: This method is not guaranteed to be concurrency-safe, and is not recommended if atomicity is a concern
      #
      def find_in_batches(options = {})
        raise "You can't specify an order, it's forced to be #{batch_order}" if options[:order]
      
        new_options = options.merge(:order=>batch_order)
        last_primary_key = new_options.delete(:start)
        start_with_zero = new_options.delete(:start_with_zero)
        start_with_zero = true if start_with_zero.nil?
        batch_size = new_options.delete(:batch_size) || 1000
        batch_offset = new_options.delete(:offset) || 0
        new_options.delete(:limit)
        new_options[:select] ||= "*"
        new_options[:select] << ",#{table_name}.#{primary_key}" # it won't hurt if this gets selected twice
        if last_primary_key.nil?
          if start_with_zero
            last_primary_key = 0
          else
            first_obj = find(:first,new_options) or return []
            last_primary_key = first_obj.send(primary_key)
          end
        end
        batch_limit=batch_size
        count = 0 # number of recs we've pulled so far
        batch_recs = []
        while true do
          if options[:limit]
            limit_remaining = options[:limit] - count
            batch_limit = (limit_remaining < batch_size) ? limit_remaining : batch_size
          end
          with_scope(:find=>new_options) do
            conditions=["#{table_name}.#{primary_key}>#{count==0 ? '=' : ''}?",last_primary_key]
            batch_recs = find(:all,:conditions=>conditions,:limit=>batch_limit,:offset=>batch_offset)
          end
          break if batch_recs.empty?
          yield batch_recs
          count += batch_recs.size
          break if (count == options[:limit])
          batch_offset=0 # we only needed this for the first batch, so we set it to 0 now
          last_primary_key = batch_recs.last.send(primary_key)
        end
        batch_recs
      end
      
      private
        def batch_order
          "#{table_name}.#{primary_key} ASC"
        end
    end
  end
end