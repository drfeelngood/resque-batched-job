module Resque
  
  module Plugin
    
    def after_batch_hooks(job)
      job.methods.grep(/^after_batch/).sort
    end
    
  end
  
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
          if batch_complete?(id)
=begin
  TODO: figure out what the hello kitty to to here.
=end
          end
        end
      end
      
      def batch_complete?(id)
        redis.scard(batch(id)) == 0
      end
      
    end
    
  end
  
end