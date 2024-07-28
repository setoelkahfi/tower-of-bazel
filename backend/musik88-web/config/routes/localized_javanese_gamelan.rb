get 'gns' => redirect('https://github.com/smbpndk/gns')
# The old index page when there was only one table.
get 'javanese_gamelan',                             to: 'javanese_gamelan#index',
                                                    as: :javanese_gamelan
get 'javanese_gending',                             to: 'javanese_gamelan#gending',
                                                    as: :javanese_gending
get 'javanese_gending_detail',                      to: 'javanese_gamelan#gending_detail',
                                                    as: :javanese_gending_detail
get 'javanese_gending_gamelan_notation',            to: 'javanese_gamelan#gamelan_notation',
                                                    as: :javanese_gending_gamelan_notation
get 'javanese_gending_gamelan_notation_detail',     to: 'javanese_gamelan#notation',
                                                    as: :javanese_gending_gamelan_notation_detail
get 'javanese_gending_gamelan_notation_detail_new', to: 'javanese_gamelan#notation_new',
                                                    as: :javanese_gending_gamelan_notation_detail_new

get     'add_gending',                      to: 'javanese_gamelan#add_gending',     as: :add_gending
post    'add_gending',                      to: 'javanese_gamelan#add_gending',     as: :add_gending
post    'javanese_gending_vote',            to: 'javanese_gamelan#gending_vote'
delete  'javanese_gending_unvote',          to: 'javanese_gamelan#gending_unvote'
post    'javanese_gending_notation_vote',   to: 'javanese_gamelan#gending_notation_vote'
delete  'javanese_gending_notation_unvote', to: 'javanese_gamelan#gending_notation_unvote'

get   'add_javanese_gamelan_notation/',     to: 'javanese_gamelan#add', as: :add_gending_notation
post  'add_javanese_gamelan_notation/',     to: 'javanese_gamelan#add', as: :add_gending_notation