workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT'] || 3000 # Don't change this since the nginx use it on production.
environment ENV['RAILS_ENV'] || 'development'

if ENV['RAILS_ENV'] == 'development'
  localhost_key = File.join('setup', 'certificates', 'localhost-key.pem').to_s
  localhost_crt = File.join('setup', 'certificates', 'localhost.pem').to_s
  # To be able to use rake etc
  ssl_bind '0.0.0.0', 3001, {
    key: localhost_key,
    cert: localhost_crt,
    verify_mode: 'none'
  }
end

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
