# Public login endpoint; management controllers inherit from Admin::BaseController.
class Admin::SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to admin_login_path, alert: "Too many attempts. Please try again in a few minutes." }

  def new
    redirect_to admin_countries_path if current_admin
  end

  def create
    # authenticate_by checks the bcrypt password without trusting a submitted role.
    user = User.authenticate_by(email: params[:email].to_s.strip.downcase,
      password: params[:password].to_s)

    # Rotate the session on login and clear any previous authentication on failure.
    reset_session
    if user&.admin?
      session[:admin_user_id] = user.id
      session[:admin_signed_in_at] = Time.current.to_i
      redirect_to admin_countries_path, notice: "Signed in successfully."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out successfully.", status: :see_other
  end
end
