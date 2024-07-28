class SongsController < ApplicationController
  def index
    meta_tags 'songs'
    @page = Page
            .select(:page_content, :title)
            .where(page_slug: 'songs', locale: [I18n.locale, I18n.default_locale])
            .last

    @songs = Song
             .select(:id, :name, :description, :updated_at, :album_id, :views_count)
             .paginate(page: params[:page], per_page: 10)

    @trending_songs = Song
                      .select(:id, :name, :description, :album_id, :views_count, :updated_at)
                      .order(views_count: :desc)
                      .limit(10)

    @most_loved_songs = Song
                        .joins(:users)
                        .select(:id, :name, :description, :updated_at, :album_id, 'COUNT(users.id) as users_count')
                        .group('songs.id')
                        .order(users_count: :desc)
                        .limit(10)
  end

  def detail
    unless valid_params?
      redirect_to root_path
      return
    end

    @lovers = @song.users
    @author = @song.user ||= User.find_by(username: 'nowhereman') # One must have nowhereman

    @page_title = t(
      'song_detail_page_title',
      song_name: @song.name
    )

    @meta_title = t(
      'song_detail_page_meta_title',
      song_name: @song.name,
      song_artist_name: @song.album.artists[0].name,
      song_album_name: @song.album.name
    )

    description       = ActionController::Base.helpers.strip_tags(@song.description.truncate(400))
    @meta_description = description.gsub('\\n', ' ').gsub(/\r\n?/, ' ')
    @meta_url         = request.url
  end

  def bridge
    meta_tags 'songs_bridge'
    return redirect_to song_path unless valid_bridge_params?

    @sf_link = "#{ENV['SF_HOST']}/split/#{@song.id}"
    @page_title = @song.name
    @meta_title = @song.name
    @meta_description = @song.description
  end

  def chords
    unless valid_params?
      redirect_to root_path
      return
    end

    @chords = Chord.where(song_id: @song.id).order(views_count: :desc)
    @lovers = @song.users
    @author = @song.user ||= User.find_by(username: 'nowhereman') # One must have nowhereman

    @page_title = t(
      'song_chords_page_title',
      song_name: @song.name
    )

    @meta_title       = @page_title
    description       = ActionController::Base.helpers.strip_tags(@song.description.truncate(400))
    @meta_description = description.gsub('\\n', ' ').gsub(/\r\n?/, ' ')
    @meta_url         = request.url
  end

  def audio
    unless valid_params?
      redirect_to root_path
      return
    end

    @audio_files    = AudioFile.where(song_provider_id: @song.id)
    @karaoke_files  = @audio_files.map(&:karaoke_file)

    @chords = Chord.where(song_id: @song.id).order(views_count: :desc)
    @lovers = @song.users
    @author = @song.user ||= User.find_by(username: 'nowhereman') # One must have nowhereman

    @page_title = t(
      'song_audio_page_title',
      song_name: @song.name
    )

    @meta_title       = @page_title
    description       = ActionController::Base.helpers.strip_tags(@song.description.truncate(400))
    @meta_description = description.gsub('\\n', ' ').gsub(/\r\n?/, ' ')
    @meta_url         = request.url
  end

  def lyrics
    unless valid_params?
      redirect_to root_path
      return
    end

    @lyrics = Lyric.where(song_id: @song.id).order(views_count: :desc)

    @page_title = t(
      'song_lyrics_page_title',
      song_name: @song.name
    )

    @meta_title       = @page_title
    description       = ActionController::Base.helpers.strip_tags(@song.description.truncate(400))
    @meta_description = description.gsub('\\n', ' ').gsub(/\r\n?/, ' ')
    @meta_url         = request.url
  end

  def karaoke
    # Simply redirect to splitfire
    redirect_to ENV['SF_HOST']
  end

  def most_loved
    @page_title = t('breadcrumb_most_loved_songs')
    @most_loved_songs = Song
                        .joins(:users)
                        .select(:id, :name, :description, :album_id, 'COUNT(users.id) as users_count')
                        .group('songs.id')
                        .order(users_count: :desc)

    @meta_title       = @page_title
    @meta_description = @page_title
    @meta_url         = request.url
  end

  def loved
    redirect_to_login && return unless user_signed_in?

    plea = SongChordPlea.new(song_id: params[:id], user_id: current_user.id)
    plea.save

    redirect_back(fallback_location: root_path)
  end

  def unloved
    redirect_to_login && return unless user_signed_in?

    plea = SongChordPlea.where(song_id: params[:id], user_id: current_user.id)
    plea.destroy_all

    redirect_back(fallback_location: root_path)
  end

  def bass_backing_track
    # Get the song_id
    id = params[:slug].split('-')[-1]
    @song = Song.find_by id: id
    @page_title = t(
      'song_karaoke_page_title',
      song_name: @song.name,
      song_artist_name: @song.album.artists[0].name,
      song_album_name: @song.album.name
    )

    @lovers = nil
    @author = nil
    @karaoke_file_shown = nil

    if @song.audio_files.count == 0
      @shown_text = t(
        'song_karaoke_unavailable_content',
        song_name: @song.name,
        song_artist_name: @song.album.artists[0].name
      )

      @meta_description = t(
        'song_karaoke_unavailable_meta_description',
        song_name: @song.name,
        song_artist_name: @song.album.artists[0].name,
        song_album_name: @song.album.name
      )

    else
      @meta_description = "#{@page_title}. #{@song.album.name}"
    end

    @meta_title = @page_title
  end

  def bass_tab
    # Simply redirect to splitfire
    redirect_to ENV['SF_HOST']
  end

  def drum_backing_track
    # Get the song_id
    id = params[:slug].split('-')[-1]
    @song = Song.find_by id: id
    @page_title = t(
      'song_karaoke_page_title',
      song_name: @song.name,
      song_artist_name: @song.album.artists[0].name,
      song_album_name: @song.album.name
    )

    @lovers = nil
    @author = nil
    @karaoke_file_shown = nil

    if @song.audio_files.count == 0
      @shown_text = t(
        'song_karaoke_unavailable_content',
        song_name: @song.name,
        song_artist_name: @song.album.artists[0].name
      )

      @meta_description = t(
        'song_karaoke_unavailable_meta_description',
        song_name: @song.name,
        song_artist_name: @song.album.artists[0].name,
        song_album_name: @song.album.name
      )

    else
      @meta_description = "#{@page_title}. #{@song.album.name}"
    end

    @meta_title = @page_title
  end

  private

  def valid_params?
    id      = params[:slug].split('-')[-1]
    @song   = Song.find_by(id: id)
    if @song.nil?
      flash[:danger] = t('not_found')
      return false
    end
    @lovers = @song.users
    @author = @song.user ||= User.find_by(username: 'nowhereman') # One must have nowhereman
    true
  end

  def valid_bridge_params?
    id      = params[:slug].split('-')[-1]
    @song   = SongProvider.find_by(id: id)
    if @song.nil?
      flash[:danger] = t('not_found')
      return false
    end
    @song_in_albums = []
    true
  end

  def redirect_to_login
    flash[:success] = t('need_to_logged_in')
    song            = Song.find_by(id: params[:id])
    redirect_to login_path(redirect_to: song_detail_path(song.slug))
  end

  def meta_tags(slug)
    meta = Meta
           .select(:title, :description)
           .where(home: slug, locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end
end
