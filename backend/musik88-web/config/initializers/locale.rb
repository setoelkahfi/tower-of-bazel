# Where the I18n library should search for translation files
I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')]

# Permitted locales available for the application
# ISO 639-1 Code
I18n.available_locales = %i[en id-id sv-se ja]
