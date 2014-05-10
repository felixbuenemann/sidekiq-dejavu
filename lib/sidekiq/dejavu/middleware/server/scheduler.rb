module Sidekiq
  module Dejavu
    module Middleware
      module Server
        class Scheduler
          include Helper

          attr_reader :schedules, :options

          def initialize(options = {})
            # Sidekiq.logger.info "Intialized #{self.class} with options #{options.inspect}"
            @schedules = Sidekiq::ScheduledSet.new
            @options = options
          end

          def call(worker, item, queue)
            start = Time.now
            interval = item['interval']
            schedule = item['schedule']

            yield

          ensure
            if interval && not_already_scheduled?(schedule)
              time = relative_to_start? ? start : Time.now
              schedule_next_run(worker, item, interval, time)
            end
          end

          private

          def not_already_scheduled?(schedule)
            !!schedule && schedules.select{ |job| job.item['schedule'] == schedule }.empty?
          end

          def schedule_next_run(worker, item, interval, from_time)
            timestamp = next_timestamp(interval, from_time)
            Sidekiq.logger.info "Scheduling #{worker.class} for #{Time.at timestamp}"
            item['at'] = timestamp
            worker.class.client_push(item)
          end

          def relative_to_start?
            !!options[:relative]
          end
        end
      end
    end
  end
end
