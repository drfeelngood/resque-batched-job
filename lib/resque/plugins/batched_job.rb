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

      # After every job, no matter in the event of success or failure, we need
      # to remove the job from the batch set.
      def around_perform_amend_batch(id, *args)
        yield
      ensure
        redis.lrem(batch(id), 1, encode(:class => self, :args => args))
      end

      # After each job is performed, check to see if the job is the last of
      # the given batch.  If so, run after_batch hooks.
      def after_perform_batch(id, *args)
        if batch_complete?(id)
          after_batch_hooks = Resque::Plugin.after_batch_hooks(self)
          after_batch_hooks.each do |hook|
            send(hook, id, *args)
          end
        end
      end

      # Checks to see if the batch key exists.  If the key does exist, is the 
      # set empty?  The Redis srem command deletes the key when the last item 
      # of a set is removed. Ah, go ahead and check the size.
      def batch_complete?(id)
        redis.llen(batch(id)) == 0
      end
      alias :batch_exist? :batch_complete? # => are they?

    end

  end

end