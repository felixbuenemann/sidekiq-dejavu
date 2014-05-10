require 'sidekiq/dejavu/version'
require 'sidekiq/dejavu/helper'
require 'sidekiq/dejavu/manager'
require 'sidekiq/dejavu/middleware/server/scheduler'

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Dejavu::Middleware::Server::Scheduler
  end

  config.on(:startup) do
    schedules = config.options.fetch(:schedule, {})
    if schedules.empty?
      Sidekiq.logger.warn "Sidekiq::Dejavu: No schedule found."
    else
      Sidekiq.logger.info "Sidekiq::Dejavu: Loading schedules #{schedules.keys.join ','}."
      Sidekiq::Dejavu::Manager.new(schedules).reload_schedule!
    end
  end
end
