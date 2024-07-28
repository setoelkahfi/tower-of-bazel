# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'https://musik88.com'
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new(
  fog_provider: 'AWS',
  aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  fog_directory: ENV['S3_BUCKET'],
  fog_region: ENV['AWS_REGION']
)
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_host = 'https://musik88.s3.amazonaws.com/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.ping_search_engines('https://musik88.com/sitemap')

SitemapGenerator::Sitemap.create do
  I18n.available_locales.each do |locale|
    I18n.locale = locale

    # Index paths
    [javanese_gending_path, javanese_gending_gamelan_notation_path, artist_path, album_path, song_path,
     lyrics_path].each do |path|
      add path, changefreq: 'daily'
    end

    JavaneseGending.find_each do |gending|
      add javanese_gending_detail_path(gending.slug), changefreq: 'daily', lastmod: gending.updated_at
    end

    JavaneseGendingNotation.find_each do |notation|
      add javanese_gending_gamelan_notation_detail_path(notation.slug), changefreq: 'daily',
                                                                        lastmod: notation.updated_at
    end

    Chord.find_each do |chord|
      add guitar_chord_detail_path(chord.slug), changefreq: 'daily', lastmod: chord.updated_at
    end

    Song.find_each do |song|
      add song_detail_path(song.slug), changefreq: 'daily', lastmod: song.updated_at
    end

    SongProvider.find_each do |song|
      add song_bridge_path(song.slug), changefreq: 'daily', lastmod: song.updated_at
    end

    ArtistProvider.find_each do |artist|
      add artist_bridge_path(artist.slug), changefreq: 'daily', lastmod: artist.updated_at
    end

    AlbumProvider.find_each do |album|
      add album_bridge_path(album.slug), changefreq: 'daily', lastmod: album.updated_at
    end

    # PAGES
    [splitfire_path, bass64_path, contact_path, term_of_use_path, privacy_policy_path, login_path,
     signup_path].each do |path|
      add path, changefreq: 'monthly'
    end
  end
end
