require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  warn e.to_s
  warn "Attempting to run pending migrations on the test database..."
    begin
      migrations_paths = if defined?(ActiveRecord::Migrator) && ActiveRecord::Migrator.respond_to?(:migrations_paths)
                           ActiveRecord::Migrator.migrations_paths
                         else
                           ActiveRecord::MigrationContext.new("db/migrate").migrations_paths
                         end

      migration_context = if ActiveRecord::Base.connection.respond_to?(:migration_context)
                            ActiveRecord::Base.connection.migration_context
                          else
                            ActiveRecord::MigrationContext.new(migrations_paths, ActiveRecord::SchemaMigration)
                          end

      migration_context.migrate
      warn "Migrations applied. Reloading schema and continuing specs."
      retry
    rescue => inner_err
      abort("Failed to run migrations programmatically: #{inner_err.message}. Please run `bin/rails db:migrate RAILS_ENV=test` manually")
    end
rescue ActiveRecord::NoDatabaseError
  warn "Test database not found. Creating and migrating test database..."
  system('bin/rails db:create RAILS_ENV=test') || abort("Failed to create test database")
  system('bin/rails db:migrate RAILS_ENV=test') || abort("Failed to migrate test database")
  retry
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
