ActiveAdmin.register Wallet do
  menu priority: 2, parent: 'Users'
  actions :all, except: %i[edit update]

  index do
    selectable_column
    column :user do |wallet|
      wallet.user.name.blank? ? wallet.user.email : wallet.user.name
    end
    column :wallet_type
    column :pubkey
    column :bach_token_account
    actions
  end

  filter :user
  filter :pubkey
  filter :bach_token_account

  show do
    attributes_table do
      row :user
      row :pubkey
      row :bach_token_account
      row :created_at
      row :updated_at
    end
  end
end
