require 'parse-cron'

module Sidekiq
  module Dejavu
    module Helper
      def next_timestamp(interval, time = Time.now)
        CronParser.new(interval).next(time).to_f
      rescue ArgumentError
        time.to_f + interval.to_f
      end

      def next_randomized_timestamp(interval, time = Time.now)
        CronParser.new(interval).next(time).to_f
      rescue ArgumentError
        time.to_f + Random.rand(interval.to_f)
      end
    end
  end
end
