Sentry.init do |config|
  config.dsn = 'https://358d28fdbcc64ec8adf63f104dbe262e@o933906.ingest.sentry.io/5883180'
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |_context|
    true
  end
  config.enabled_environments = %w[production]
end
