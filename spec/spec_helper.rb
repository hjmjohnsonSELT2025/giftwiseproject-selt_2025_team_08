require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
end

ENV['GOOGLE_API_KEY'] ||= 'test-key-for-testing-only'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
