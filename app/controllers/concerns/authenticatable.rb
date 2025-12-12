# app/controllers/concerns/authenticatable.rb
module Authenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_signed_in?
  end

  def authenticate_user!
    redirect_to new_session_path, alert: "É necessário fazer login." unless user_signed_in?
  end

  def current_user
    Current.session&.user
  end

  def user_signed_in?
    current_user.present?
  end
end
