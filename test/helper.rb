# disable minitest/parallel threads
ENV["N"] = "0"

require "bundler/setup"

require "sidekiq"
require "sidekiq/api"
require "sidekiq/testing"

require "minitest/autorun"
require "yaml"
require "pry" unless ENV['CI']

require "sidekiq/dejavu"

require_relative "fixtures/dummy_worker"

require 'sidekiq/redis_connection'
REDIS_URL = ENV['REDIS_URL'] || 'redis://localhost/15'
REDIS = Sidekiq::RedisConnection.create(:url => REDIS_URL, :namespace => 'dejavu_test')

Sidekiq.configure_client do |config|
  config.redis = { :url => REDIS_URL, :namespace => 'dejavu_test' }
end

Sidekiq::Testing.disable!
Sidekiq::Testing.server_middleware do |chain|
  chain.add Sidekiq::Dejavu::Middleware::Server::Scheduler
end

class Sidekiq::Dejavu::Test < MiniTest::Test
  attr_reader :log, :scheduled_set

  def setup
    # capture logger
    @old_logger = Sidekiq.logger
    @log = StringIO.new
    Sidekiq.logger = Logger.new(@log)
    # clear scheduled set
    @scheduled_set = Sidekiq::ScheduledSet.new
    @scheduled_set.clear
  end

  def teardown
    Sidekiq::Worker.drain_all
    Sidekiq.logger = @old_logger
  end

  def assert_logged(regex)
    assert_match log, regex
  end
end
