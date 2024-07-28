# frozen_string_literal: true

localized do
  root  'welcome#index'
  get   'search', to: 'welcome#search', as: :search

  # Routes from the splitfire project
  draw(:localized_my)
  # Accounts
  draw(:localized_accounts)

  draw(:localized_tools)

  draw(:localized_pages)

  draw(:localized_contents)

  draw(:localized_javanese_gamelan)

  draw(:localized_commentable)
end
