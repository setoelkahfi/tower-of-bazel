class AboutController < ApplicationController
  def index
    meta_tags

    @page = Page
            .select(:page_content, :title)
            .where(page_slug: 'about-us', locale: [I18n.locale, I18n.default_locale])
            .last
    @page_title = t('nav_footer_about')
  end

  def contact
    meta_tags

    @page = Page
            .select(:page_content, :title)
            .where(page_slug: 'contact', locale: [I18n.locale, I18n.default_locale])
            .last
    @page_title = t('nav_footer_contact')
  end

  def term
    @meta_title = 'Koleksi lirik lagu baru, lirik lagu pop, informasi musik terkini | Lyrics88.Com'
    @meta_description = 'Temukan koleksi lirik lagu baru yang sedang populer: lirik lagu pop, ' +
                        'lirik lagu rock, lirik lagu Indonesia. Koleksi lagu Indonesia selalu diperbarui.'

    # @page = Page.find_by page_slug: 'terms-of-use', locale: I18n.locale
    @page_title = t('nav_footer_term')
  end

  def privacy
    @meta_title = 'Koleksi lirik lagu baru, lirik lagu pop, informasi musik terkini | Lyrics88.Com'
    @meta_description = 'Temukan koleksi lirik lagu baru yang sedang populer: lirik lagu pop, ' +
                        'lirik lagu rock, lirik lagu Indonesia. Koleksi lagu Indonesia selalu diperbarui.'

    # @page = Page.find_by page_slug: 'privacy-policy', locale: I18n.locale
    @page_title =  t('nav_footer_privacy')
  end

  def sitemap
    redirect_to "https://#{ENV['S3_BUCKET']}.s3.amazonaws.com/sitemaps/sitemap.xml.gz"
  end

  def bach
    @page = Page.select(:id, :page_content).where(page_slug: 'bach', locale: [I18n.locale, I18n.default_locale]).last
    meta_tags
  end

  private

  def meta_tags
    meta              = Meta
                        .select(:title, :description)
                        .where(home: 'bach', locale: [I18n.locale, I18n.default_locale])
                        .last
    @meta_title       = meta.title if meta
    @meta_description = meta.description if meta
    @meta_url         = request.url
  end
end
