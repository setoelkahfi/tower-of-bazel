get     '@:username',                           to: 'users#show',                     as: :profile
get     '@:username/user_rep',                  to: 'users#show_reputation',          as: :show_reputation
get     '@:username/friends',                   to: 'users#friends',                  as: :friends
get     '@:username/following',                 to: 'users#following',                as: :following
get     '@:username/followers',                 to: 'users#followers',                as: :followers
get     '@:username/settings',                  to: 'users#settings',                 as: :settings
post    '@:username/settings_activate_solana',  to: 'users#settings_activate_solana', as: :settings_activate_solana
post    '@:username/settings_locale',           to: 'users#settings_locale',          as: :settings_locale
put     '@:username/update_settings',           to: 'users#update_settings',          as: :update_settings
resources :relationships, only: %i[create destroy]

get 'users/:id', to: redirect { |_params, request| "/@#{request.params[:id]}" }

get     'community',            to: 'users#community',        as: :community
get     'login',                to: 'sessions#new',           as: :login
post    'login',                to: 'sessions#create',        as: :login
post    'login_pubkey',         to: 'sessions#create_pubkey', as: :login_pubkey
# Deprecated in favor of clicking link from login page error flash message.
get     'confirm_email',        to: 'sessions#confirm_email', as: :confirm_email
post    'confirm_email',        to: 'sessions#confirm_email', as: :confirm_email
get     'signup',               to: 'users#new',              as: :signup
post    'signup',               to: 'users#create',           as: :signup
get     'onboarding',           to: 'users#onboarding',       as: :onboarding
post    'onboarding_action',    to: 'users#onboarding_action', as: :onboarding_action
get     'username_check',       to: 'users#username_check',   as: :username_check
post    'username',             to: 'users#username',         as: :username
post    'onboarding_export_spotify', to: 'users#onboarding_export_spotify', as: :onboarding_export_spotify
post    'onboarding_export_youtube', to: 'users#onboarding_export_youtube', as: :onboarding_export_youtube
