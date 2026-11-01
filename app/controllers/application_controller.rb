class ApplicationController < ActionController::Base
  helper_method :current_admin

  # Recheck the saved role on every request; sessions expire after eight hours.
  def current_admin
    return @current_admin if defined?(@current_admin)

    signed_in_at = session[:admin_signed_in_at].to_i
    if session[:admin_user_id].present? && signed_in_at > 8.hours.ago.to_i
      user = User.find_by(id: session[:admin_user_id])
      @current_admin = user if user&.admin?
    end
    @current_admin ||= nil
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
