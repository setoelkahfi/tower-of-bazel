class WelcomeController < ApplicationController
  QUERY_LIMIT_AUTOCOMPLETE = 5
  QUERY_LIMIT_SEARCH_PAGE = 10_000

  def index
    meta_tags 'home'
    @template = 'main'
  end

  def search
    @keywords = params[:s]
    return if @keywords.nil?

    meta_tags 'search'
    @results = merge_search(QUERY_LIMIT_SEARCH_PAGE)
  end

  private

  def meta_tags(slug)
    meta = Meta
           .select(:title, :description)
           .where(home: slug, locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title       = meta.title if meta
    @meta_description = meta.description if meta
    @meta_url         = root_url
  end

  def merge_search(limit)
    keyword = params[:s].downcase
    search_gending_notation(keyword, limit) + search_gending(keyword, limit) +
      search_artist(keyword, limit) + search_song_provider(keyword, limit) + search_album(keyword, limit)
  end

  def search_song(keywords, limit)
    Song
      .where('lower(name) LIKE ?', "%#{keywords}%")
      .limit(limit)
      .as_json(only: %i[id name]) +
      search_song_provider(keywords, limit)
  end

  def search_artist(keywords, limit)
    Artist
      .where('lower(name) LIKE ?', "%#{keywords}%")
      .limit(limit)
      .as_json(only: %i[id name]) +
      search_artist_provider(keywords, limit)
  end

  def search_album(keywords, limit)
    Album
      .where('lower(name) LIKE ?', "%#{keywords}%")
      .limit(limit)
      .as_json(only: %i[id name]) +
      search_album_provider(keywords, limit)
  end

  def search_album_provider(keywords, limit)
    AlbumProvider
      .where('lower(name) LIKE ?', "%#{keywords}%")
      .limit(limit)
      .as_json(only: %i[id name])
  end

  def search_artist_provider(keywords, limit)
    ArtistProvider
      .where('lower(name) LIKE ?', "%#{keywords}%")
      .limit(limit)
      .as_json(only: %i[id name])
  end

  def search_song_provider(keywords, limit)
    SongProvider
      .where('lower(name) LIKE ?', "%#{keywords}%")
      .limit(limit)
      .as_json(only: %i[id name])
  end

  def search_gending(keywords, limit)
    JavaneseGending
      .where('lower(name) LIKE ?', "%#{keywords}%")
      .limit(limit)
      .as_json(only: %i[id name])
  end

  def search_gending_notation(keywords, limit)
    JavaneseGendingNotation
      .where('lower(name) LIKE ?', "%#{keywords}%")
      .limit(limit)
      .as_json(only: %i[id name])
  end
end
