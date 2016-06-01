require 'timeout'

DISABLED_TASKS = [
    'db:drop',
    'db:drop:all',
    'db:fixtures:load',
    'db:migrate:reset',
    'db:reset',
    'db:schema:load',
    'db:seed',
    'db:setup',
    'db:structure:load'
]

namespace :db do

  task :recreate => ['guard:not_for_production'] do
    Rake::Task['db:disconnect'].invoke rescue nil
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
  end

  desc 'Truncate database'
  task :truncate => ['guard:not_for_production', :environment, :logging] do
    begin
      Timeout::timeout(15) do
        Rails.logger.info "Truncating database #{Rails.env}"
        DatabaseCleaner.strategy = :truncation
        LiveTestingMode.both { DatabaseCleaner.clean_with :truncation }
      end
    rescue Timeout::Error
      Rails.logger.error 'Truncate method timed out.'
    end
  end

  desc 'Disconnect database users'
  task :disconnect => ['guard:not_for_production', :environment, :logging] do
    Rails.logger.info 'Disconnecting all database users'

    sql = <<-SQL
        SELECT pg_terminate_backend(pg_stat_activity.pid)
        FROM pg_stat_activity
        WHERE pg_stat_activity.datname = current_database()
        AND pid <> pg_backend_pid();
    SQL

    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.connection.execute(sql)
  end


  desc 'Truncates and seeds the database'
  task :reseed => ['guard:not_for_production', :disconnect, :truncate, :seed]
end

DISABLED_TASKS.each do |task|
  Rake::Task[task].enhance ['guard:not_for_production']
end
