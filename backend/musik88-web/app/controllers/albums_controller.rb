class AlbumsController < ApplicationController
  def index
    meta_tags 'albums'

    @page = Page
            .select(:page_content, :title)
            .where(page_slug: 'albums', locale: [I18n.locale, I18n.default_locale])
            .last

    @albums = Album
              .includes(:artists)
              .select(:id, :name, :views_count, :description, :updated_at)
              .where(album_artists: { primary: true })
              .references(:artists)
              .paginate(page: params[:page], per_page: 10)

    @trending_albums = Album
                       .includes(:artists)
                       .select(:id, :name, :views_count, :description, :updated_at)
                       .where(album_artists: { primary: true })
                       .references(:artists)
                       .order(views_count: :desc)
                       .limit(10)
  end

  def detail
    @page_title_artist  = t('album_artists')
    @page_title_songs   = t('album_song_list')

    album_id = params[:slug].split('-')[-1]
    @album = Album
             .select('albums.id, albums.name, albums.user_id, albums.description, albums.views_count')
             .find_by id: album_id

    return redirect_to album_path unless @album

    @artists = Artist
               .select('artists.id, artists.name')
               .joins(:album_artists)
               .where(album_artists: { album_id: @album.id })
               .order('album_artists.primary DESC')

    @page_title = @album.name

    meta_tags 'album_detail'
    @album.increment!(:views_count) unless browser.bot?
  end

  def bridge
    @page_title_artist  = t('album_artists')
    @page_title_songs   = t('album_song_list')

    album_id = params[:slug].split('-')[-1]
    @album = AlbumProvider
             .select(:id, :name, :user_id, :provider_id, :provider_type)
             .find_by(id: album_id)

    return redirect_to album_path unless @album

    @page_title = @album.name

    meta_tags 'album_detail'
  end

  def add
    if request.post?
      album = Album.new(album_params)
      unless album.save
        flash[:warning] = "We need at the album's title and description."
        redirect_to album_add_path
        return
      end
      redirect_to album_detail_path(album.slug)
    end

    @album      = Album.new(name: params[:name], description: params[:description])
    @user       = user_signed_in? ? current_user : User.find_by(username: 'nowhereman')
    @page_title = 'Add Album'

    @meta_title       = @page_title
    @meta_description = @page_title
  end

  def vote
    return redirect_to login_path unless user_signed_in?

    vote = AlbumVote.new(album_id: params[:id], user_id: current_user.id)
    vote.save

    redirect_back(fallback_location: root_path)
  end

  def unvote
    return redirect_to login_path unless user_signed_in?

    vote = AlbumVote.where(album_id: params[:id], user_id: current_user.id)
    vote.destroy_all

    redirect_back(fallback_location: root_path)
  end

  private

  def album_params
    params
      .require(:album)
      .permit(:name, :description, :user_id)
  end

  def meta_tags(slug)
    meta = Meta
           .select(:title, :description)
           .where(home: slug, locale: [I18n.locale, I18n.default_locale])
           .last
    @meta_title       = meta.title if meta
    @meta_description = meta.description if meta
  end
end
