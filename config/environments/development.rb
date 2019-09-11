Rails.application.configure do
  
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true
  # config.cache_store = :mem_cache_store

  # Don't care if the mailer can't send.
  config.active_job.queue_adapter = :sidekiq
  
  config.action_mailer.raise_delivery_errors = true
  # config.action_mailer.delivery_method = :mailgun
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.mailgun_settings = {
    api_key: "#{SECRET['MAILGUN_API_KEY']}",
    domain: "#{SECRET['MAILGUN_SMTP_DOMAIN']}"
  }
  config.action_mailer.smtp_settings = {
    address:              "#{SECRET['MAILGUN_SMTP_ADDRESS']}",
    port:                 587,
    domain:               "#{SECRET['MAILGUN_SMTP_DOMAIN']}",
    user_name:            "#{SECRET['MAILGUN_SMTP_UN']}",
    password:             "#{SECRET['MAILGUN_SMTP_PW']}",
    authentication:       'plain',
    enable_starttls_auto: true
  }
  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  config.paperclip_defaults = {
    :storage => :s3,
    :preserve_files => true,
    :s3_credentials => {
      :bucket => "#{SECRET['AWS']['S3']['BUCKET_NAME']}",
      :access_key_id => "#{SECRET['AWS']['ACCESS_KEY_ID']}",
      :secret_access_key => "#{SECRET['AWS']['SECRET_ACCESS_KEY']}"
    },
    :s3_region => "us-east-1"
  }

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  # config.action_controller.asset_host = "http://0.0.0.0"
  config.after_initialize do
    Bullet.enable = false
    Bullet.alert = false
    Bullet.bullet_logger = false
    Bullet.console = true
  end
end
