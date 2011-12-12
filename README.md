# Resque Batched Job

A [Resque](http://github.com/defunkt/resque) plugin. Requires Resque >= 1.10.0

This plugin adds the ability to batch jobs and run additional hooks after the 
last job in a batch is performed.  Using the '*after_enqueue*' hook, the job
is encoded and stored in a Redis List identified by the batch id provided.  By default, 
the batch keys look like '*batch:#{id}*'.  After each job is performed, it's removed
from the batch list.  If the last job performed happens to be the last in the list, 
additional hooks are executed.  These hooks are prefixed with '*after_batch*'.

## Installation

    $ gem install resque-batched-job

## Example

```ruby
require 'resque/batched_job'

module Job
  extend Resque::Plugins::BatchedJob

  def self.perform(id, *args)
    prime(id, args)
  end

  def self.after_batch_heavy_lifting(id, *args)
    heavy_lifting(id)
  end

end
```
