class ChordsController < ApplicationController
  def index
    meta = Meta
           .select(:title, :description)
           .where(home: 'guitar_chords', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title       = meta.title if meta
    @meta_description = meta.description if meta

    @page = Page
            .select(:page_content, :title)
            .where(page_slug: 'guitar_chords', locale: [I18n.locale, I18n.default_locale])
            .last

    @chords = Chord
              .select(:id, :views_count, :song_provider_id, :updated_at, :title)
              .order(updated_at: :desc)
              .paginate(page: params[:page], per_page: 10)

    @trending_chords = Chord
                       .select(:id, :views_count, :song_provider_id, :updated_at, :title)
                       .order(views_count: :desc)
                       .limit(10)
  end

  def guitar_shapes
    @meta_title = 'Koleksi chord gitar lagu artis-artis terbaru, artis pop, informasi artis terkini | Lyrics88.Com'
    @meta_description = 'Koleksi chord gitar lagu artis-artis terbaru, artis pop, informasi artis terkini | Lyrics88.Com'

    @page = Page
            .select(:page_content, :title)
            .find_by page_slug: 'guitar_chords_shapes'

    @chords = ChordShape
              .select(:id, :name)
              .all
  end

  def guitar_shape
    @meta_title = 'Koleksi chord gitar lagu artis-artis terbaru, artis pop, informasi artis terkini | Lyrics88.Com'
    @meta_description = 'Koleksi chord gitar lagu artis-artis terbaru, artis pop, informasi artis terkini | Lyrics88.Com'

    @chords = ChordShape
              .select(:id, :name)
              .all
    id = params[:slug].split('-')[-1]
    @chord = ChordShape.find_by id: id
  end

  def chord
    id = params[:slug].split('-')[-1]
    @chord = Chord.find_by(id: id)

    if @chord.nil?
      render_chord_nil
      meta
    else
      render_chord
      meta
    end
  end

  def history
    id = params[:slug].split('-')[-1]
    @chord = Chord.find_by(id: id)

    return redirect_to guitar_chords_path if @chord.nil?

    @chord_histories = ChordHistory.where(chord_id: id).order(updated_at: :desc)

    @song = @chord.song_provider
    @page_title = if @song.nil?
                    @chord.title
                  else
                    t(
                      'song_chord_page_title',
                      song_name: @song.name
                    )
                  end

    @chords = Chord.where(song_id: @song.id) unless @song.nil?
    @chord.increment!(:views_count) unless browser.bot?

    @author = @chord.user.nil? ? 'nowhereman' : @chord.user.username_or_id

    @meta_title = @page_title
    @meta_description = @page_title
  end

  def add
    @chord            = Chord.new
    @user             = current_user
    @page_title       = t('add_chord_title')
    @meta_title       = @page_title
    @meta_description = @page_title
  end

  def add_post
    @chord = Chord.new(chord_params)

    re_render_add && return unless @chord.save

    add_chord_history
    flash[:success] = t('add_chord_validation_success')
    redirect_to guitar_chord_detail_path(@chord.slug)
  end

  def re_render_add
    @user             = current_user
    @page_title       = t('add_chord_title')
    @meta_title       = @page_title
    @meta_description = @page_title
    @chord_artists    = chord_artists_link

    flash[:warning]   = t('add_chord_validation')
    render :add
  end

  def chord_artists_link
    @chord.song
          &.artists
          &.map { |a| view_context.link_to(a.name, artist_detail_path(a.slug)) }
          &.join(' ')
          &.html_safe
  end

  def song_search
    render json: Song
      .where('lower(name) LIKE ?', "%#{params[:s].downcase}%")
      .as_json(only: %i[id name])
  end

  def review
    id = params[:slug].split('-')[-1]
    @chord = Chord.find_by(id: id)

    redirect_to guitar_chords_path and return if @chord.nil?

    unless @chord.pending?
      flash[:warning] = 'Already approved.'
      redirect_to guitar_chord_detail_path and return
    end

    if request.patch?
      unless user_signed_in?
        flash[:warning] = 'Please login to review.'
        redirect_to guitar_chord_detail_path and return
      end

      unless current_user.reviewer?
        flash[:warning] = 'You have to have 10 €BACH to review.'
        redirect_to guitar_chord_review_path
        return
      end

      @chord.update_attribute(:status, :approved)

      chord_history = ChordHistory.new(
        chord_id: @chord.id,
        user_id: current_user.id,
        name: 'Approved'
      )
      unless chord_history.save
        # Revert
        @chord.update_attribute(:status, :pending)
        flash[:warning] = 'Unknown error'
        redirect_to guitar_chord_review_path
        return
      end

      flash[:success] = 'Approved!'
      redirect_to guitar_chord_detail_path(@chord.slug)
      return
    end

    @song = @chord.song_provider
    @page_title = if @song.nil?
                    @chord.title
                  else
                    t(
                      'song_chord_page_title',
                      song_name: @song.name
                    )
                  end

    @chords = Chord.where(song_id: @song.id) unless @song.nil?
    @chord.increment!(:views_count) unless browser.bot?

    @author = @chord.user.nil? ? 'nowhereman' : @chord.user.username_or_id

    @meta_title = @page_title
    @meta_description = @page_title
  end

  def vote
    redirect_to_login && return unless user_signed_in?

    vote = ChordVote.new(chord_id: params[:id], user_id: current_user.id)
    vote.save

    redirect_back(fallback_location: root_path)
  end

  def unvote
    redirect_to_login && return unless user_signed_in?

    vote = ChordVote.where(chord_id: params[:id], user_id: current_user.id)
    vote.destroy_all

    redirect_back(fallback_location: root_path)
  end

  private

  def chord_params
    params
      .require(:chord)
      .permit(:title, :chord, :user_id, :song_id)
  end

  def redirect_to_login
    flash[:success] = t('need_to_logged_in')
    chord           = Chord.find_by(id: params[:id])
    redirect_to login_path(redirect_to: guitar_chord_detail_path(chord.slug))
  end

  def add_chord_history
    chord_history = ChordHistory.new(
      chord_id: @chord.id,
      user_id: @chord.user_or_nowhereman.id,
      name: 'Submitted'
    )
    chord_history.save
  end

  def render_chord
    @song = @chord.song_provider
    @page_title = chord_page_title
    @chord_content = chord_content
    @chords = Chord.where(song_id: @song.id) unless @song.nil?
    @chord.increment!(:views_count) unless browser.bot?
    @author = @chord.user.nil? ? 'nowhereman' : @chord.user.username_or_id
  end

  def render_chord_nil
    @page_title = 'Chord is not found'
  end

  def chord_content
    if user_signed_in?
      @chord.chord
    else
      song_name = @song&.name || @chord.title
      t('join_our_chord_community', song_name: song_name)
    end
  end

  def chord_page_title
    if @song.nil?
      @chord.title
    else
      t(
        'song_chord_page_title',
        song_name: @song.name
        # Should call Spotify API here to get the artist name
      )
    end
  end

  def meta
    @meta_title = @page_title
    @meta_description = @page_title
  end
end
