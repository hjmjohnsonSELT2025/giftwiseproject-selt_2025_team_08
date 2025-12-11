if defined?(Rails)
  Rails.application.config.after_initialize do
    if defined?(Puma) || defined?(WEBrick) || defined?(Thin) || defined?(Unicorn)
      Rails.logger.info "[NotificationScheduler] Starting notification scheduler on boot..."
      NotificationScheduler.start
    end
  end

  at_exit do
    if NotificationScheduler.running?
      Rails.logger.info "[NotificationScheduler] Stopping notification scheduler..."
      NotificationScheduler.stop
    end
  end
end
