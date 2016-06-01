require File.expand_path('../application', __FILE__)
require "#{Rails.root}/lib/strong_config"

# Optional local config that is not committed to git
def merge_local_config(app_config)
  if local = YAML.load_file("#{Rails.root}/config/local_config.yml")
    env = local[Rails.env]
    app_config.deep_merge!(env) unless env.nil?
    puts "Merged local_config.yml into app_config.yml:\n#{JSON.pretty_generate(local)}"
  end
rescue Errno::ENOENT => ex
  #   local_config.yml not found - be silent
rescue => ex
  puts "Error merging local_config.yml into app_config.yml: #{ex.inspect}"
end


begin
  APP_CONFIG = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]
  merge_local_config(APP_CONFIG) if Rails.env.development?

  begin
    AppConfig = StrongConfig.build(APP_CONFIG)
  rescue => ex
    puts "Error initializing strong AppConfig: #{ex.inspect}"
  end
rescue => ex
  puts "Error loading configs: #{ex.inspect}"
end


Rails.application.initialize!
