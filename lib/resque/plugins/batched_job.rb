module Resque

  module Plugin

    # This hook is really the meaning of our adventure.
    def after_batch_hooks(job)
      job.methods.grep(/^after_batch/).sort
    end

  end

  module Plugins

    module BatchedJob

      include Resque::Helpers

      # Helper method used to generate the batch key.
      def batch(id)
        "batch:#{id}"
      end

      # Batch the job.  The first argument of a batched job, is the batch id.
      def after_enqueue_batch(id, *args)
        redis.rpush(batch(id), encode(:class => self, :args => args))
      end

      # After the job is performed, remove it from the batched job list.  If the
      # current job is the last in the batch to be performed, invoke the after_batch
      # hooks.
      def after_perform_batch(id, *args)
        redis.lrem(batch(id), 1, encode(:class => self, :args => args))
        if batch_complete?(id)
          after_batch_hooks = Resque::Plugin.after_batch_hooks(self)
          after_batch_hooks.each do |hook|
            send(hook, id, *args)
          end
        end
      end

      # Checks the size of the batched job list and returns true if the list is
      # empty or if the key does not exist.
      def batch_complete?(id)
        redis.llen(batch(id)) == 0
      end

      def batch_exist?(id)
        redis.exists(batch(id))
      end

    end

  end

end