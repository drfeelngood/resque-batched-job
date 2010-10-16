module Resque
  
  module Plugins
    
    module BatchedJob
    
      include Resque::Helpers

      def batch(id)
        "batch:#{id}"
      end

      def after_enqueue_amend_batch(id, *args)
        redis.sadd(batch(id), encode(args))
      end

      def before_perform_audit_batch(id, *args)
        # unless redis.sismember(batch(id), "#{encode(args)}")
        #   raise Resque::Job::DontPerform.new("#{args} are not a member of #{batch(id)}")
        # end
      end

      def around_perform_amend_batch(id, *args)
        begin
          yield
        ensure # => removal of batch item
          redis.srem(batch(id), "#{encode(args)}")
        end
      end
      
    end
    
  end
  
end