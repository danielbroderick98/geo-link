# Enforce permissions before any administrator action can read or change data.
class Admin::BaseController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    if current_admin
      response.set_header("Cache-Control", "no-store")
    elsif session[:admin_user_id].present?
      reset_session
      head :forbidden
    else
      redirect_to admin_login_path, alert: "Please sign in as an administrator."
    end
  end
end
