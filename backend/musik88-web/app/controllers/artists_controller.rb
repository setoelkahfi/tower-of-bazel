class ArtistsController < ApplicationController
  def index
    meta = Meta
           .select(:title, :description)
           .where(home: 'artists', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title       = meta.title if meta
    @meta_description = meta.description if meta

    @page = Page
            .select(:page_content, :title)
            .where(page_slug: 'artists', locale: [I18n.locale, I18n.default_locale])
            .last

    @artists = Artist
               .select(:id, :name, :description, :views_count, :updated_at)
               .paginate(page: params[:page], per_page: 12)

    @trending_artists = Artist
                        .select(:id, :name, :description, :views_count, :updated_at)
                        .order(views_count: :desc)
                        .limit(10)
  end

  def detail
    artist_id = params[:slug].split('-')[-1]
    @artist   = Artist
                .select(:id, :name, :description, :user_id, :views_count)
                .find_by(id: artist_id)

    redirect_to artist_path and return if @artist.nil?

    @page_title       = t('artist_profile_title', artist: @artist.name)
    @page_title_album = t('artist_profile_album_title', artist: @artist.name)

    @albums = Album
              .joins(:album_artists)
              .where(album_artists: { artist_id: @artist.id, primary: true })

    @page_title_album_contribute_to = t('artist_profile_album_contribution_title', artist: @artist.name)
    @albums_contribute_to           = Album
                                      .select('albums.id, albums.name')
                                      .joins(:album_artists)
                                      .where(album_artists: { artist_id: @artist.id, primary: false })
    @primary_artists = []
    @albums_contribute_to.each do |album|
      artist = Artist
               .select('artists.name')
               .joins(:album_artists)
               .where(album_artists: { album_id: album.id, primary: true })
               .first

      @primary_artists.push(artist.name) if artist
    end

    description       = ActionController::Base.helpers.strip_tags(@artist.description.truncate(400))
    @meta_title       = @page_title
    @meta_description = description.gsub('\\n', ' ').gsub(/\r\n?/, ' ')
    @meta_url         = request.url

    @artist.increment!(:views_count) unless browser.bot?
  end

  def bridge
    artist_id = params[:slug].split('-')[-1]
    @artist   = ArtistProvider
                .select(:id, :name, :provider_type, :user_id, :provider_id)
                .find_by(id: artist_id)

    redirect_to artist_path and return if @artist.nil?

    @page_title = @artist.name
  end

  def add
    if request.post?
      artist = Artist.new(artist_params)
      unless artist.save
        flash[:warning] = "We need at the artist's name and description."
        redirect_to artist_add_path
        return
      end
      redirect_to artist_detail_path(artist.slug)
    end

    @artist     = Artist.new(name: params[:name], description: params[:description])
    @user       = user_signed_in? ? current_user : User.find_by(username: 'nowhereman')
    @page_title = 'Add artist'

    @meta_title       = @page_title
    @meta_description = @page_title
  end

  def vote
    return redirect_to login_path unless user_signed_in?

    vote = ArtistVote.new(artist_id: params[:id], user_id: current_user.id)
    vote.save

    redirect_back(fallback_location: root_path)
  end

  def unvote
    return redirect_to login_path unless user_signed_in?

    vote = ArtistVote.where(artist_id: params[:id], user_id: current_user.id)
    vote.destroy_all

    redirect_back(fallback_location: root_path)
  end

  private

  def artist_params
    params
      .require(:artist)
      .permit(:name, :description, :user_id)
  end
end
