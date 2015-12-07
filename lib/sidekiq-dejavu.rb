require "sidekiq"
require "sidekiq/dejavu"

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Dejavu::Middleware::Server::Scheduler
  end

  config.on(:startup) do
    schedules = config.options[:schedule] || {}
    Sidekiq.logger.debug "Sidekiq::Dejavu: schedules: #{schedules.inspect}"
    if schedules.empty?
      Sidekiq.logger.warn "Sidekiq::Dejavu: No schedule found."
    else
      Sidekiq.logger.info "Sidekiq::Dejavu: Loading schedules #{schedules.keys.join ','}."
      Sidekiq::Dejavu::Manager.new(schedules).reload_schedule!
    end
  end
end
