module UsersHelper
  # Returns the gravatar for the given user
  def gravatar_for(user)
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, class: 'img-thumbnail rounded-circle mx-auto d-block')
  end

  def nowhereman
    User.find_by(username: 'nowhereman')
  end

  def locale_index(locale)
    I18n.available_locales.find_index(locale)
  end
end
