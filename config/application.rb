require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CustomersCart
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Rails 3.2+ manipulates JSON arrays:
    # 1. Empty arrays become nil. E.g. [] becomes nil
    # 2. Nils within arrays are removed. E.g. [1, 2, nil, 3] becomes [1, 2, 3]
    # WTF. This is for a security hole in ActiveRecord SQL generation.
    # https://github.com/rails/rails/issues/13420 but messes with valid JSON and thus reasonable
    # and necessary API design. Thankfully, this will finally be fixed properly in 5.0
    # https://speakerdeck.com/claudiob/rails-5-awesome-features-and-breaking-changes
    # Since risk is edge case it is being circumvented for now.
    config.action_dispatch.perform_deep_munge = false

    config.autoload_paths += %W(#{config.root}/lib)

    Dir[File.join(Rails.root, "lib", "core_ext", "*.rb")].each { |l| require l }

    config.generators do |g|
      g.fixture_replacement :factory_girl
    end

    MIGRATION = File.basename($0) == 'rake' && (ARGV.any? { |arg| arg[/db:recreate/] || arg[/db:migrate/] || arg[/db:restore/] })
  end
end
