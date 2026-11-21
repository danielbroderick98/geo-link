# Enforce permissions before any administrator action can read or change data.
class Admin::BaseController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    if current_admin
      # Keep admin pages out of the browser cache because they contain management controls.
      response.set_header("Cache-Control", "no-store")
    elsif session[:admin_user_id].present?
      # Clear an expired session or one whose account no longer has admin access.
      reset_session
      head :forbidden
    else
      redirect_to admin_login_path, alert: "Please sign in as an administrator."
    end
  end
end
