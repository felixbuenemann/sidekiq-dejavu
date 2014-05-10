# Sidekiq::Dejavu

Dejavu is a clockless scheduler that uses Sidekiq's built-in scheduling.

Most scheduling solutions for Sidekiq require either a separate cron like process
or run an internal clock thread inside sidekiq server to manage schedules.

Dejavu uses Sidekiq's internal scheduling, like `Sidekiq::Worker.perform_in`
and `Sidekiq::Worker.perform_at` so it doesn't need its own clock process/thread
and integrates nicely with Sidekiq without duplicating any functionality.

## Note

This is **ALPHA** quality code and doesn't yet have any specs, so make sure you test it well.
Requires Sidekiq 3.0 or later. Compatibility with older versions could probably be added.

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

## Contributing

1. Fork it ( https://github.com/felixbuenemann/sidekiq-dejavu/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
