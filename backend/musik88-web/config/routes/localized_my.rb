# Private pages
get     'my',               to: redirect('my/profile')
get     'my/profile',       to: 'my#index',             as: :my_profile
get     'my/profile/edit',  to: 'my#edit',              as: :my_profile_edit

# My Lyrics
get 'my/add-lyric/:song_id', to: 'my#add_lyric', as: :add_lyric
get 'my/edit-lyric/:id', to: 'my#edit_lyric', as: :edit_lyric
post 'my/add-lyric/:song_id', to: 'my#add_lyric', as: :add_lyric
patch 'my/edit-lyric/:id', to: 'my#edit_lyric', as: :edit_lyric
get 'my/lyrics', to: 'my#lyrics', as: :my_lyrics

# My Files
get     'my/files',       to: 'my#files',       as: :my_files
get     'my/files/:id',   to: 'my#file_detail', as: :my_file_detail
post    'my/files',       to: 'my#files',       as: :my_files             # Add file
delete  'my/files/:id',   to: 'my#files',       as: :my_delete_file       # Delete file

get     'my/admin-files', to: 'my#admin_files', as: :my_admin_files

# My SplitFire
get     'my/splitfire',           to: 'my#splitfire',           as: :my_splitfire
get     'my/splitfire/:id',       to: 'my#splitfire_detail',    as: :my_splitfire_detail
patch   'my/splitfire/:id',       to: 'my#splitfire_cancel',    as: :my_splitfire_cancel
delete  'my/splitfire/:id',       to: 'my#splitfire_delete',    as: :my_splitfire_delete
post    'my/splitfire/:id',       to: 'my#splitfire_start',     as: :my_splitfire_start
patch   'my/splitfire_settings',  to: 'my#splitfire_settings',  as: :my_splitfire_settings

# My Bass64
get     'my/bass64',      to: 'my#bass64',        as: :my_bass64
post    'my/bass64/:id',  to: 'my#bass64_start',  as: :my_bass64_start
patch   'my/bass64/:id',  to: 'my#bass64_cancel', as: :my_bass64_cancel
get     'my/bass64/:id',  to: 'my#bass64_detail', as: :my_bass64_detail
delete  'my/bass64/:id',  to: 'my#bass64_delete', as: :my_bass64_delete

# My KaroKowe
get     'my/karokowe',      to: 'my#karokowe',        as: :my_karokowe
post    'my/karokowe/:id',  to: 'my#karokowe_start',  as: :my_karokowe_start
patch   'my/karokowe/:id',  to: 'my#karokowe_cancel', as: :my_karokowe_cancel
get     'my/karokowe/:id',  to: 'my#karokowe_detail', as: :my_karokowe_detail
delete  'my/karokowe/:id',  to: 'my#karokowe_delete', as: :my_karokowe_delete

# My Bonzo
get     'my/bonzo',      to: 'my#bonzo',        as: :my_bonzo
post    'my/bonzo/:id',  to: 'my#bonzo_start',  as: :my_bonzo_start
patch   'my/bonzo/:id',  to: 'my#bonzo_cancel', as: :my_bonzo_cancel
get     'my/bonzo/:id',  to: 'my#bonzo_detail', as: :my_bonzo_detail
delete  'my/bonzo/:id',  to: 'my#bonzo_delete', as: :my_bonzo_delete
# END Private pages
