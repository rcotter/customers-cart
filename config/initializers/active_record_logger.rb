# Set log levels via app_config.yml or local_config.yml
# Vales, as per http://guides.rubyonrails.org/v2.3.11/debugging_rails_applications.html#log-levels
# but, using integers in the yml.
#
# 0  # Logger::DEBUG
# 1  # Logger::INFO
# 2  # Logger::WARN
# 3  # Logger::ERROR
# 4  # Logger::FATAL
# 5  # Logger::UNKNOWN

ActiveRecord::Base.logger.level = AppConfig.log_level || Logger::INFO