module ApplicationHelper
  def current_class?(*paths)
    paths.each do |path|
      return 'current-item' if request.path == path
    end
  end

  def current_class_mobile?(path)
    request.path.start_with?(path) ? 'selected' : ''
  end

  def production?
    request.domain == 'wwww.musik88.com' || request.domain == 'musik88.com'
  end

  def link_to_host_locale(locale, path_with_locale)
    path = path_with_locale.split(locale.to_s)[1]

    path = '' if path.nil?

    host_locale = ''
    RouteTranslator.config.host_locales.each do |locale_array|
      host_locale = locale_array[0] if locale_array[1].to_s == locale.to_s

      host_locale + ":#{request.port}"
    end
    host_locale + path
  end

  def current_domain_locale_url(locale_code, params)
    domains = domains_map
    ## Loop through all locales and get the path
    I18n.available_locales.each do |locale|
      path = url_for(locale: locale.to_s, only_path: true, params: params)
      unless locale == :en || path.start_with?('/users')
        path = path.sub('/', '').split('/')[1..].join('/').insert(0,
                                                                  '/')
      end
      host = domains[locale]
      domains[locale] = "#{host}#{path}"
    end

    domains[locale_code]
  end

  CanonicalUrl = Struct.new(:url, :locale)

  def canonical_urls
    # The canonical url is en locale in .com domain
    domain = if Rails.env.development?
               "http://com.musik88:#{request.port}"
             elsif Rails.env.production?
               'https://www.musik88.com'
             end

    urls_with_locale = []

    I18n.available_locales.each do |locale|
      canonical_url = CanonicalUrl.new

      path = url_for(locale: locale.to_s, only_path: true)

      canonical_url.url = domain + path
      canonical_url.locale = locale

      urls_with_locale.push(canonical_url)
    end

    urls_with_locale
  end

  def name_or_username(user)
    user.username.nil? ? user.name : "@#{user.username}"
  end

  def profile_path_enhanced(user)
    profile_path(user.username || user.id)
  end

  def artist_friendly_url(artist)
    "#{artist.name.downcase.parameterize}-#{artist.id}"
  end

  def album_friendly_url(album)
    "#{album.name.downcase.parameterize}-#{album.artists[0].name.downcase.parameterize}-#{album.id}"
  end

  private

  def domains_map
    domains = {}
    host    = Rails.env.production? ? request.host : request.host_with_port
    I18n.available_locales.each do |locale|
      locale_suffix = "/#{locale}" unless locale == :en || request.path.start_with?('/users')
      domains[locale] = "#{request.protocol}#{host}#{locale_suffix}"
    end
    domains
  end
end
