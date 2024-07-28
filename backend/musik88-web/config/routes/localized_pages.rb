get     'about_us',                     to: 'about#index',              as: :about_us
get     'term_of_use',                  to: 'about#term',               as: :term_of_use
get     'privacy_policy',               to: 'about#privacy',            as: :privacy_policy
get     'contact',                      to: 'about#contact',            as: :contact
get     'BACH',                         to: 'about#bach',               as: :bach
get     'bach',                         to: redirect('BACH')
