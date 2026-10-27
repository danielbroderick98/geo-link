# Use the same parent controller as your other admin controllers.
class Admin::TreatyParticipantsController < ApplicationController
  def index
    # Prepare an empty record for the form.
    @treaty_participant = TreatyParticipant.new
    load_page_data
  end

  def create
    # Build a participant using only the permitted dropdown values.
    @treaty_participant = TreatyParticipant.new(treaty_participant_params)

    if @treaty_participant.save
      redirect_to admin_treaty_participants_path,
      notice: "Treaty participant added successfully."
    else
      # Reload the dropdowns and table while keeping validation errors.
      load_page_data
      render :index, status: :unprocessable_entity
    end
  end

  private

  def load_page_data
    # Populate both dropdowns alphabetically.
    @treaties = Treaty.order(:name)
    @countries = Country.order(:name)

    # Load associated records together to avoid a separate database
    # query for every treaty and country displayed in the table.
    @treaty_participants = TreatyParticipant
      .includes(:treaty, :country)
      .order(:id)
  end

  def treaty_participant_params
    # Only accept the two foreign keys from the form.
    params.require(:treaty_participant).permit(:treaty_id, :country_id)
  end
end
