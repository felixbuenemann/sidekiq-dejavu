require_relative "helper"

class TestHelper < Sidekiq::Dejavu::Test
  include Sidekiq::Dejavu::Helper

  def time
    @time ||= Time.now
  end

  def test_valid_cron_with_valid_cron
    interval = '* * * * *'
    assert_equal true, valid_cron?(interval)
  end

  def test_valid_cron_with_interval
    [10, 10.0, '10', '10.0'].each do |interval|
      assert_equal false, valid_cron?(interval)
    end
  end

  def test_valid_cron_with_garbage
    interval = 'garbage'
    assert_equal false, valid_cron?(interval)
  end

  def test_next_timestamp_cron
    interval = '* * * * *'
    expected = time.to_f + (60 - time.to_f % 60)
    assert_equal expected, next_timestamp(interval, time)
  end

  def test_next_timestamp_numeric
    expected = time.to_f + 10.0
    [10, 10.0, '10', '10.0'].each do |interval|
      assert_equal expected, next_timestamp(interval, time)
    end
  end

  def test_next_randomized_timestamp_cron
    interval = '* * * * *'
    expected = time.to_f + (60 - time.to_f % 60)
    timestamp = next_randomized_timestamp(interval, time)
    another_timestamp = next_randomized_timestamp(interval, time)

    assert_in_delta expected, timestamp, 60.0
    refute_equal expected, timestamp
    refute_equal timestamp, another_timestamp
  end

  def test_next_randomized_timestamp_numeric
    expected = time.to_f + 10.0
    [10, 10.0, '10', '10.0'].each do |interval|
      timestamp = next_randomized_timestamp(interval, time)
      another_timestamp = next_randomized_timestamp(interval, time)

      assert_in_delta expected, timestamp, 10.0
      refute_equal expected, timestamp
      refute_equal timestamp, another_timestamp
    end
  end
end
