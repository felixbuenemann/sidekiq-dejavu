require_relative "helper"

class TestManager < Sidekiq::Dejavu::Test
  def schedules
    @schedules ||= YAML.load(<<-YAML).freeze
      foo:
        interval: 10
        class: DummyWorker
        args:
          - fooarg
      bar:
        interval: '30 5 * * *'
        class: DummyWorker
        args:
          - bararg
    YAML
  end

  def test_reload_schedule!
    manager = Sidekiq::Dejavu::Manager.new schedules

    assert_equal 0, scheduled_set.size
    manager.reload_schedule!
    assert_equal 2, scheduled_set.size

    foo = scheduled_set.find { |job| job.item['schedule'] == 'foo' }
    assert foo
    assert_equal 10, foo.item['interval']
    assert_equal 'DummyWorker', foo.item['class']
    assert_equal %w(fooarg), foo.item['args']

    bar = scheduled_set.find { |job| job.item['schedule'] == 'bar' }
    assert bar
    assert_equal '30 5 * * *', bar.item['interval']
    assert_equal 'DummyWorker', bar.item['class']
    assert_equal %w(bararg), bar.item['args']
  end

  def test_reload_schedule_clears_old_schedules
    old_schedules = YAML.load <<-YAML
      old:
        interval: 15
        class: DummyWorker
    YAML

    manager = Sidekiq::Dejavu::Manager.new old_schedules
    assert_equal 0, scheduled_set.size
    manager.reload_schedule!
    assert_equal 1, scheduled_set.size

    assert scheduled_set.find { |job| job.item['schedule'] == 'old' }

    manager.schedules = {}
    assert_equal 1, scheduled_set.size
    manager.reload_schedule!
    assert_equal 0, scheduled_set.size

    refute scheduled_set.find { |job| job.item['schedule'] == 'old' }
  end

  def test_reload_schedule_updates_existing_schedules
    old_schedules = YAML.load <<-YAML
      foo:
        interval: 15
        class: DummyWorker
        args:
          - oldfooarg
      bar:
        interval: '15 4 * * *'
        class: DummyWorker
        args:
          - oldbararg
    YAML

    manager = Sidekiq::Dejavu::Manager.new old_schedules

    assert_equal 0, scheduled_set.size
    manager.reload_schedule!
    assert_equal 2, scheduled_set.size

    foo = scheduled_set.find { |job| job.item['schedule'] == 'foo' }
    assert foo
    assert_equal 15, foo.item['interval']
    assert_equal 'DummyWorker', foo.item['class']
    assert_equal %w(oldfooarg), foo.item['args']

    bar = scheduled_set.find { |job| job.item['schedule'] == 'bar' }
    assert bar
    assert_equal '15 4 * * *', bar.item['interval']
    assert_equal 'DummyWorker', bar.item['class']
    assert_equal %w(oldbararg), bar.item['args']

    manager.schedules = schedules
    assert_equal 2, scheduled_set.size
    manager.reload_schedule!
    assert_equal 2, scheduled_set.size

    foo = scheduled_set.find { |job| job.item['schedule'] == 'foo' }
    assert foo
    assert_equal 10, foo.item['interval']
    assert_equal 'DummyWorker', foo.item['class']
    assert_equal %w(fooarg), foo.item['args']

    bar = scheduled_set.find { |job| job.item['schedule'] == 'bar' }
    assert bar
    assert_equal '30 5 * * *', bar.item['interval']
    assert_equal 'DummyWorker', bar.item['class']
    assert_equal %w(bararg), bar.item['args']
  end

  def test_reload_schedule_keeps_unchanged_schedules
    manager = Sidekiq::Dejavu::Manager.new schedules
    assert_equal 0, scheduled_set.size
    manager.reload_schedule!
    assert_equal 2, scheduled_set.size

    manager.schedules = schedules
    manager.reload_schedule!
    assert_equal 2, scheduled_set.size
  end
end
