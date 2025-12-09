require 'rails_helper'

RSpec.describe CheckNotificationsJob, type: :job do
  describe '#perform' do
    it 'calls NotificationService.check_and_send_reminders' do
      expect(NotificationService).to receive(:check_and_send_reminders)
      CheckNotificationsJob.new.perform
    end

    it 'executes successfully without errors' do
      expect { CheckNotificationsJob.perform_now }.not_to raise_error
    end

    it 'responds to perform' do
      job = CheckNotificationsJob.new
      expect(job).to respond_to(:perform)
    end

    it 'has queue set to default' do
      expect(CheckNotificationsJob.new.class.queue_name).to eq('default')
    end
  end
end
