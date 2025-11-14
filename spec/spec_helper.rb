require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
