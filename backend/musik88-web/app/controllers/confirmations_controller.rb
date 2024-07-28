class ConfirmationsController < Devise::ConfirmationsController
  layout 'new_confirmation', only: %i[new create]
  layout 'edit_confirmation', only: %i[edit update]

  protected

  def after_confirmation_path_for(_resource_name, _resource)
    login_path
  end

  def after_resending_confirmation_instructions_path_for(_resource_name)
    login_path
  end
end
