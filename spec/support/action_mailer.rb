RSpec.configure do |config|
  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  config.before(:each) do
    ActionMailer::Base.delivery_method = :test
  end
end
