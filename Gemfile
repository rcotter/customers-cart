source 'https://rubygems.org'


gem 'rails', '4.2.6'
gem 'i18n'

gem 'attribute_normalizer', '~> 1.2'      # Model attribute normalizer https://github.com/mdeering/attribute_normalizer
gem 'basic_auth_credentials', '~> 1.0.0'  # Parse basic auth header
gem 'bcrypt', '~> 3.1.7'                  # Password and key encryption
gem 'jbuilder', '~> 2.0'                  # JSON view DSL
gem 'money-rails'                         # Money Gem for handling amounts
gem 'responders', '~> 2.0'                # Responder modules to dry up your Rails 4.2+ app

# Assets
gem 'jquery-rails'
gem 'less-rails'
gem 'turbolinks'
gem 'therubyracer'
gem 'uglifier', '>= 1.3.0'


group :development, :test do
  gem 'faker'                 # Fake data generator
  gem 'mailcatcher'           # Local SMTP server that receives emails and displays in browser http://mailcatcher.me/
  gem 'rspec-its'             # One-liner specs
  gem 'rspec-rails'           # Testing framework
  gem 'spring-commands-rspec' # rspec command for Spring
end

group :development do
  gem 'annotate'              # Model annotation
  gem 'web-console', '~> 2.0' # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'spring'                # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
end

group :test do
  gem 'shoulda-matchers', require: false # RSpec-compatible one-liners that test common Rails functionality. Require explicitly after rails is loaded via spec_helper.rb
  gem 'shoulda-callback-matchers', '~> 1.1.1'
end

