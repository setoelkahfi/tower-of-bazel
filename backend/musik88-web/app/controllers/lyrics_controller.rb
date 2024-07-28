class LyricsController < ApplicationController
  def index
    meta = Meta
           .select(:title, :description)
           .where(home: 'song_lyrics', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title       = meta.title if meta
    @meta_description = meta.description if meta
    @meta_url         = request.url

    @page = Page
            .select(:page_content, :title)
            .where(page_slug: 'song_lyrics', locale: [I18n.locale, I18n.default_locale])
            .last

    @lyrics = Lyric
              .select(:id, :views_count, :song_id)
              .paginate(page: params[:page], per_page: 100)

    @trending_lyrics = @lyrics
                       .order(views_count: :desc)
                       .limit(10)
  end

  def lyric
    lyric_id  = params[:slug].split('-')[-1]
    @lyric    = Lyric.find_by(id: lyric_id)

    redirect_to root_path and return unless @lyric.present?

    @lovers = @lyric.users
    @author = @lyric.user
    @song   = @lyric.song

    unless user_signed_in?
      flash[:warning] = t(
        'join_our_lyric_community',
        song_name: @song&.name,
        song_artist_name: @song.artists.first&.name || 'NaN'
      )
      redirect_to signup_path(redirect_to: request.path)
    end

    @page_title = t(
      'song_lyric_page_title',
      song_name: @song&.name,
      song_artist_name: @song.artists.first&.name || 'NaN'
    )

    @lyric_shown = @lyric.lyric.gsub('\\n', '<br>')
    @author = @lyric.user
    @meta_description = "#{@page_title}. #{@lyric.lyric.gsub('\\n', ' ').gsub(/\r\n?/, '')[0..300].strip}"

    @lyric.increment!(:views_count) unless browser.bot?

    @meta_title = @page_title
  end

  def lyric_not_available
    if @lyric.nil?
      shown_text = t(
        'song_lyric_unavailable_content',
        song_name: @song.name,
        song_artist_name: @song.album.artists[0].name,
        href: ActionController::Base.helpers.link_to(
          t('song_lyric_unavailable_content_add_lyric'),
          add_lyric_path(@song.id),
          class: 'bb-button bb-green bb-large'
        )
      )
      @lyric_shown = "<p class='lead'>#{shown_text}</p>"
      @meta_description = t(
        'song_lyric_unavailable_meta_description',
        song_name: @song.name,
        song_artist_name: @song.album.artists[0].name,
        song_album_name: @song.album.name
      )

    end
  end
end
