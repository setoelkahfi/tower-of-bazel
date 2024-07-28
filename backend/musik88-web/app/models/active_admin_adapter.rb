class ActiveAdminAdapter < ActiveAdmin::AuthorizationAdapter
  def authorized?(_action, _subject = nil)
    user && (user.id == 1 || user.username == 'seto' || user.admin?)
  end
end
