class JavaneseGamelanController < ApplicationController
  def index
    meta_tags('javanese-gamelan')
    page('javanese-gamelan')

    @gendings = JavaneseGending
                .select(:id, :name, :views_count, :updated_at, :description)
                .order(created_at: :desc)
                .paginate(page: params[:page], per_page: 10)

    @trending_gendings = @gendings.order(views_count: :desc).limit(10)
  end

  def gending
    meta_tags('gending')
    page('gending')
    @gendings = JavaneseGending
                .select(:id, :name, :user_id, :views_count, :updated_at, :description)
                .order(created_at: :desc)
                .paginate(page: params[:page], per_page: 10)
  end

  def gending_detail
    id = params[:slug].split('-')[-1]
    @gending = JavaneseGending.find_by(id: id)

    return redirect_to javanese_gending_path unless @gending

    @author           = @gending.user_or_nowhereman
    @page_title       = t('gending_notation_page_title', title: @gending.name)
    @meta_title       = @page_title
    @meta_description = t('gending_notation_meta_desciption', title: @gending.name)

    @gending.increment!(:views_count) unless browser.bot?
  end

  # The naming inconsistency between gamelan and gending is for the sake of SEO.
  def gamelan_notation
    meta_tags('javanese-gamelan-notation')
    page('javanese-gamelan-notation')
    @gending_notations = JavaneseGendingNotation
                         .select(:id, :user_id, :name, :rich_format, :views_count, :updated_at)
                         .order(created_at: :desc)
                         .paginate(page: params[:page], per_page: 10)
  end

  # Detail notation
  def notation
    render_notation
  end

  def notation_new
    render_notation_new
  end

  def add_gending
    @javanese_gending = JavaneseGending.new
    meta_tags('javanese-gamelan-notation')
  end

  def add
    if request.post?
      @javanese_gending = JavaneseGending.new(javanese_gending_params)
      if @javanese_gending.save
        redirect_to javanese_gamelan_path
      else
        flash[:warning] = t('lyric_cannot_be_empty')
        redirect_to add_lyric_path(@lyric.song_id)
      end

      return
    end

    @javanese_gending = JavaneseGending.new
    meta_tags('javanese-gamelan-notation')
  end

  def gending_vote
    return redirect_to login_path unless user_signed_in?

    vote = GendingVote.new(javanese_gending_id: params[:id], user_id: current_user.id)
    vote.save
    redirect_back(fallback_location: root_path)
  end

  def gending_unvote
    return redirect_to login_path unless user_signed_in?

    vote = GendingVote.where(javanese_gending_id: params[:id], user_id: current_user.id)
    vote.destroy_all
    redirect_back(fallback_location: root_path)
  end

  def gending_notation_vote
    return redirect_to login_path unless user_signed_in?

    vote = GendingNotationVote.new(javanese_gending_notation_id: params[:id], user_id: current_user.id)
    vote.save
    redirect_back(fallback_location: root_path)
  end

  def gending_notation_unvote
    return redirect_to login_path unless user_signed_in?

    vote = GendingNotationVote.where(javanese_gending_notation_id: params[:id], user_id: current_user.id)
    vote.destroy_all
    redirect_back(fallback_location: root_path)
  end

  private

  def render_notation
    check_valid_slug

    @content_notation = content_notation
    notation_info
  end

  def render_notation_new
    check_valid_slug
    @content_notation = content_notation_new
    notation_info
  end

  def check_valid_slug
    id        = params[:slug].split('-')[-1]
    @gending  = JavaneseGendingNotation.find_by(id: id)
    return redirect_to javanese_gending_gamelan_notation_path if @gending.nil?
  end

  def content_notation
    if user_signed_in?
      @gending.notation
    else
      t('join_our_javanese_community', gending_name: @gending.name)
    end
  end

  def content_notation_new
    if user_signed_in?
      'partial_new_notation'
    else
      t('join_our_javanese_community', gending_name: @gending.name)
    end
  end

  def notation_info
    @author           = @gending.user_or_nowhereman
    @page_title       = t('gending_notation_page_title', title: @gending.name)
    @meta_title       = @page_title
    @meta_description = t('gending_notation_meta_desciption', title: @gending.name)
    @gending.increment!(:views_count) unless browser.bot?
  end
  def javanese_gending_params
    params
      .require(:javanese_gending)
      .permit(:name, :description, :notation)
  end

  def page(slug)
    @page = Page
            .select(:page_content, :title)
            .where(page_slug: slug, locale: [I18n.locale, I18n.default_locale])
            .last
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
