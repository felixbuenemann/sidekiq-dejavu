# Sidekiq::Dejavu

Dejavu is a clockless scheduler that uses Sidekiq's built-in scheduling.

Most scheduling solutions for Sidekiq require either a separate cron like process
or run an internal clock thread inside sidekiq server to manage schedules.

Dejavu uses Sidekiq's internal scheduling, like `Sidekiq::Worker.perform_in`
and `Sidekiq::Worker.perform_at` so it doesn't need its own clock process/thread
and integrates nicely with Sidekiq without duplicating any functionality.

Scheduled jobs can be controlled through the Scheduled page in the Sidekiq::Web UI.

## Note

This is **BETA** quality code and doesn't yet have any specs, so make sure you test it well.
Requires Sidekiq 3.0 or later. Compatibility with older versions could probably be added.

Warning aside, this code has run in production since October 2014 and has scheduled several
million jobs without any issues. So if you want a very lightweight scheduler give it a shot.

## Known Bugs

- Incompatible with sidekiq-unique-jobs (jobs don't get scheduled)
- It's currently possible to have multiple workers from the same schedule running in parallel
and all re-scheduling themselves. This is because jobs get re-scheduled if there is no existing
schedule with the same name, but only the scheduled jobs queue is inspected.
Depending on the intervals used it is possible that the job gets scheduled and run again before
the other jobs can see the scheduled job, so they get re-scheduled as well.
- It's possible for jobs to be scheduled multiple times, if multiple processes load the same schedule
at the same time due to missing locks around loading the schedule.

## Installation

Add this line to your application's Gemfile:

    gem 'sidekiq-dejavu'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-dejavu

## Usage

You can configure schedule tasks in your config/sidekiq.yml:

    :schedule:
      hello_world:
        interval: 10
        class: HelloWorldWorker
        queue: hello
        retry: false
        backtrace: false
        args:
          - Hello
          - World
      cleanup:
        interval: '30 5 * * *' # every day at 5:30
        class: HelloWorldWorker
        queue: hello
        retry: false
        backtrace: false
        args:
          - Hello
          - World

Interval can be specified in seconds or as a cron expression, including vixie cron syntax.

If a job fails or takes longer than an interval it will be retried at the next interval. In most cases you should set jour jobs to `retry: false` to keep Sidekiq's retries from competing with the scheduled jobs.

You also need to set all options for the job, because currently a workers `sidekiq_options` are ignored. The minium required options for a schedule are `interval` and `class`. The same worker can be scheduled multiple times by using different schedule names (keys) in the config.

Note that by default sidekiq polls scheduled jobs roughly every 15 seconds, which means in order to run jobs at shorter intervals youd'd have to tune `config.average_scheduled_poll_interval` to a lower value.

## Contributing

1. Fork it ( https://github.com/felixbuenemann/sidekiq-dejavu/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
