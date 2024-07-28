Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'api_constraints'

  # TODO: Authenticated
  mount Tolk::Engine => '/sloth', :as => 'tolk'
  mount Sidekiq::Web => '/c2lkZWtpcQ=='
  mount ActionCable.server => '/cable'
  mount Split::Dashboard, at: '/hatch'
  Split::Dashboard.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username),
                                                ::Digest::SHA256.hexdigest(ENV['SPLIT_USERNAME'])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password),
                                                  ::Digest::SHA256.hexdigest(ENV['SPLIT_PASSWORD']))
  end

  # Use a single User model for both ActiveAdmin and application frontend.
  ActiveAdmin.routes(self)

  devise_for :users, controllers: {
    sessions: 'sessions',
    omniauth_callbacks: 'users/omniauth_callbacks',
    confirmations: 'confirmations',
    passwords: 'passwords'
  }

  delete  'logout',   to: 'sessions#destroy'
  get     'sitemap',  to: 'about#sitemap'
  match   '/404',     to: 'errors#not_found',             via: :all
  match   '/500',     to: 'errors#internal_server_error', via: :all

  draw(:api)
  draw(:localized)
end
