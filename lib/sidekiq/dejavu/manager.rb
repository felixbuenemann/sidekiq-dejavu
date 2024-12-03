module Sidekiq
  module Dejavu
    class Manager
      include Helper

      attr_accessor :schedules, :scheduled_set

      def initialize(schedules = {}, scheduled_set = Sidekiq::ScheduledSet.new)
        @schedules = deep_transform_keys_to_strings(schedules)
        @scheduled_set = scheduled_set
      end

      def reload_schedule!
        clear_changed_schedules
        add_new_schedules
      end

      def scheduled_jobs
        scheduled_set.select { |job| job.item.has_key? 'schedule' }
      end

      private

      def deep_transform_keys_to_strings(hash)
        hash.each_with_object({}) do |(key, value), obj|
          new_key = key.to_s
          new_value = value.is_a?(Hash) ? deep_transform_keys_to_strings(value) : value
          obj[new_key] = new_value
        end
      end

      def clear_changed_schedules
        scheduled_jobs.each do |job|
          item = job.item
          name = item['schedule']

          unless schedules.has_key? name
            Sidekiq.logger.info "Clearing schedule #{name} (not listed in config)."
            job.delete
            next
          end

          schedule_options = schedules[name]
          schedule_options['args'] = Array(schedule_options['args'])
          item_options = item.select { |k,v| schedule_options.keys.include? k }

          if item_options != schedule_options
            Sidekiq.logger.info "Clearing schedule #{name} (config changed)."
            job.delete
          end
        end
      end

      def add_new_schedules
        existing = scheduled_jobs.map { |job| job.item['schedule'] }

        schedules.each do |name, options|
          next if existing.include? name

          args = Array(options['args'])
          interval = options['interval']
          first_run = valid_cron?(interval) ? next_timestamp(interval) : next_randomized_timestamp(interval)
          job = options.merge('args' => args, 'schedule' => name, 'at' => first_run)

          Sidekiq.logger.info "Scheduling #{name} for first run at #{Time.at first_run}."
          Sidekiq::Client.push(job)
        end
      end
    end
  end
end
