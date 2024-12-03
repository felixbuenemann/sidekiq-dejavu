source 'https://rubygems.org'

# Specify your gem's dependencies in sidekiq-dejavu.gemspec
gemspec

gem "sidekiq", ENV['SIDEKIQ'] if ENV['SIDEKIQ']
gem "minitest"
gem "minitest-utils"
gem "redis-namespace"
gem "pry" unless ENV['CI']
