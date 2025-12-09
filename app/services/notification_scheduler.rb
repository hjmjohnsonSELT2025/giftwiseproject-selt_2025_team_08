class NotificationScheduler
  @@scheduler_thread = nil
  @@scheduler_running = false

  class << self
    def start
      return if @@scheduler_running
      
      @@scheduler_running = true
      @@scheduler_thread = Thread.new { run_scheduler }
      @@scheduler_thread.abort_on_exception = true
    end

    def stop
      if @@scheduler_thread
        @@scheduler_running = false
        @@scheduler_thread.kill
        @@scheduler_thread = nil
      end
    end

    def running?
      @@scheduler_running
    end

    private

    def run_scheduler
      loop do
        begin
          sleep_duration = 60
          sleep(sleep_duration)
          
          if @@scheduler_running
            CheckNotificationsJob.perform_now
            Rails.logger.info "[NotificationScheduler] Job executed successfully at #{Time.current}"
          end
        rescue StandardError => e
          Rails.logger.error "[NotificationScheduler] Error during notification check: #{e.message}\n#{e.backtrace.join("\n")}"
          sleep(60)
        end
      end
    end
  end
end
