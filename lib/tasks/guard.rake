namespace :guard do

  desc 'Disable a task in production environment'
  task :not_for_production do
    if Rails.env.production?
      puts 'Task is disabled in production'
      exit
    end
  end
end