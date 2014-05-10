module Sidekiq
  module Dejavu
    class Manager
      include Helper

      attr_reader :schedules

      def initialize(schedules)
        @schedules = schedules
      end

      def reload_schedule!
        clear_changed_schedules
        add_new_schedules
      end

      private

      def clear_changed_schedules
        scheduled_jobs.each do |job|
          item = job.item
          name = item['schedule']
          schedule_options = schedules[name]
          item_options = item.select { |k,v| schedule_options.keys.include? k }
          if item_options != schedule_options
            Sidekiq.logger.info "Clearing schedule #{name} (config changed)."
            job.delete
          else
            schedules.delete(name)
          end
        end
      end

      def add_new_schedules
        schedules.each do |name, options|
          args = Array(options['args'])
          interval = options['interval']
          first_run = next_randomized_timestamp(interval)
          job = options.merge('args' => args, 'schedule' => name, 'at' => first_run)

          Sidekiq.logger.info "Scheduling #{name} for first run at #{Time.at first_run}."
          Sidekiq::Client.push(job)
        end
      end

      def scheduled_jobs
        Sidekiq::ScheduledSet.new.select { |job| schedules.keys.include? job.item['schedule'] }
      end
    end
  end
end
