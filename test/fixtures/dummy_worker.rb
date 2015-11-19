class DummyWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :dejavu_test
  def perform(*)
  end
end
