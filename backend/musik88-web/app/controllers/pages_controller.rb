class PagesController < ApplicationController
  def what_is_this
    meta_tags 'what_is_this'
    what_are_these

    # The page content itself
    @page = Page
            .select(:page_content, :title, :locale)
            .where(category: :about, page_slug: 'what-is-this', locale: [I18n.locale, I18n.default_locale])
            .last
  end

  def what_is_this_detail
    slug  = params[:slug]
    @page = Page
            .select(:page_content, :title, :locale)
            .where(category: :what_is_this, page_slug: slug, locale: [I18n.locale, I18n.default_locale])
            .last
    if @page.nil?
      logger.info "Page not found: #{slug}"
      return redirect_to what_is_this_path
    end

    render_detail
  end

  private

  def what_are_these
    # List of what_is_this
    @what_are_these = Page
                      .select(:page_content, :title, :page_slug)
                      .where(category: :what_is_this, locale: [I18n.locale, I18n.default_locale])
  end

  def meta_tags(home)
    meta              = Meta
                        .select(:title, :description)
                        .where(home: home, locale: [I18n.locale, I18n.default_locale])
                        .last
    @meta_title       = meta.title if meta
    @meta_description = meta.description if meta
    @meta_url         = request.url
  end

  def render_detail
    meta_tags 'what_is_this_detail'
    what_are_these

    # Override meta title and meta description
    @meta_title       = @page.title
    @meta_description = @page.page_content[0..100]

    render 'what_is_this'
  end
end
