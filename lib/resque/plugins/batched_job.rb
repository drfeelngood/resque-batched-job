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
      # (closes #2)
      def after_enqueue_batch(id, *args)
        mutex(id) do |bid|
          redis.rpush(bid, encode(:class => self.name, :args => args))
        end
      end

      # After the job is performed, remove it from the batched job list.  If the
      # current job is the last in the batch to be performed, invoke the after_batch
      # hooks.
      def after_perform_batch(id, *args)
        remove_batched_job(id, *args)

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
        mutex(id) do |bid| 
          redis.llen(bid) == 0
        end
      end

      def batch_exist?(id)
        mutex(id) do |bid| 
          redis.exists(bid)
        end
      end

      # Remove a job from the batch list. (closes #6)
      def remove_batched_job(id, *args)
        mutex(id) do |bid|
          redis.lrem(bid, 1, encode(:class => self.name, :args => args))
        end
      end

      private

        # Lock a batch key before executing Redis commands.  This will ensure
        # no race conditions occur when modifying batch information.  Here is
        # an example of how this works.  See http://redis.io/commands/setnx for
        # more information. (fixes #4) (closes #5)
        # 
        # * Job2 sends SETNX batch:123:lock in order to aquire a lock.
        # * Job1 still has the key locked, so Job2 continues into the loop.
        # * Job2 sends GET to aquire the lock timestamp.
        # * If the timestamp does not exist (Job1 released the lock), Job2 
        #   attemps to start from the beginning again.
        # * If the timestamp exists and has not expired, Job2 sleeps for a 
        #   moment and then retries from the start.
        # * If the timestamp exists and has expired, Job2 sends GETSET to aquire
        #   a lock.  This returns the previous value of the lock.
        # * If the previous timestamp has not expired, another process was faster
        #   and aquired the lock.  This means Job2 has to start from the beginnig.
        # * If the previous timestamp is still expired the lock has been set and
        #   processing can continue safely
        def mutex(id, &block)
          is_expired = lambda do |locked_at|
            locked_at.to_f < Time.now.to_f
          end
          bid   = batch(id)
          _key_ = "#{bid}:lock"

          until redis.setnx(_key_, Time.now.to_f + 0.5)
            next unless timestamp = redis.get(_key_)

            unless is_expired.call(timestamp)
              sleep(0.1)
              next
            end

            break unless timestamp = redis.getset(_key_, Time.now.to_f + 0.5)
            break if is_expired.call(timestamp)
          end
          yield(bid)
        ensure
          redis.del(_key_)
        end

    end

  end

end