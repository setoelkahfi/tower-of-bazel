# Create application badges (uses https://github.com/norman/ambry)
Rails.application.reloader.to_prepare do
  Merit::Badge.create!(
    id: 1,
    name: 'pretty-path',
    description: 'A user has a username. Pretty, huh?',
    custom_fields: { icon_path: 'media/images/badge-pretty.gif' }
  )
  Merit::Badge.create!(
    id: 2,
    name: 'spotify-exporter',
    description: 'I am doing an export-import.',
    custom_fields: { icon_path: 'media/images/badge-spotify-exporter.gif' }
  )
  Merit::Badge.create!(
    id: 3,
    name: 'youtube-exporter',
    description: 'I am doing an export-import.',
    custom_fields: { icon_path: 'media/images/badge-youtube-exporter.gif' }
  )
end
