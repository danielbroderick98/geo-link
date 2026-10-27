class Admin::TreatiesController < ApplicationController
  # Find the saved treaty before editing, updating, or deleting it.
  before_action :set_treaty, only: [:edit, :update, :destroy]

  def index
    # Load the treaty list and the countries available in the form.
    load_management_page

    # Prepare an empty treaty for the Add a treaty form.
    @treaty = Treaty.new
  end

  def new
    # Treaty creation happens on the management page.
    redirect_to admin_treaties_path
  end

  def create
    # Restore the entered details and selected countries.
    # This object has not been saved to the database.
    @treaty = Treaty.new(treaty_params)

    if country_selection_request?
      # Add or remove a country, then redisplay the form.
      # Do not save the treaty yet.
      change_country_selection
      load_management_page

      render :index, status: form_response_status
    elsif @treaty.save
      # Save the treaty and its selected countries together.
      redirect_to admin_treaties_path,
        notice: "Treaty added successfully."
    else
      # Preserve the entered values and show validation errors.
      load_management_page

      render :index, status: :unprocessable_entity
    end
  end

  def edit
    # Keep a reference to the saved treaty so the form submits
    # to its update route.
    @editing_treaty = @treaty

    load_countries
  end

  def update
    # Identify which saved treaty the edit form is updating.
    @editing_treaty = @treaty

    if country_selection_request?
      # Use an unsaved object while choosing countries.
      # This prevents country selections from changing the database
      # before Save changes is clicked.
      @treaty = Treaty.new(treaty_params)

      change_country_selection
      load_countries

      render :edit, status: form_response_status
    elsif @treaty.update(treaty_params)
      # Save the edited details and selected countries.
      redirect_to admin_treaties_path,
        notice: "Treaty updated successfully."
    else
      # Redisplay the edit form with its values and errors.
      load_countries

      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Delete the treaty. Associated participant records are removed
    # by the model's dependent: :destroy association.
    if @treaty.destroy
      redirect_to admin_treaties_path,
        notice: "Treaty deleted successfully.",
        status: :see_other
    else
      # Show a message if a model callback prevents deletion.
      redirect_to admin_treaties_path,
        alert: "Treaty could not be deleted.",
        status: :see_other
    end
  end

  private

  def set_treaty
    # Find the treaty whose ID was supplied in the URL.
    @treaty = Treaty.find(params[:id])
  end

  def load_management_page
    # Sort the saved treaties alphabetically.
    @treaties = Treaty.order(:name)

    load_countries
  end

  def load_countries
    # Supply the country dropdown in alphabetical order.
    @countries = Country.order(:name)
  end

  def country_selection_request?
    # Distinguish Add country / Remove submissions from
    # Add treaty / Save changes submissions.
    params[:country_action] == "add" ||
      params[:country_action].to_s.match?(/\Aremove:\d+\z/)
  end

  def change_country_selection
    if params[:country_action] == "add"
      # Look up the country selected in the dropdown.
      country = Country.find_by(id: params[:selected_country_id])

      if country
        # Add the country ID and prevent duplicate selections.
        @treaty.country_ids = (
          @treaty.country_ids + [country.id]
        ).uniq
      else
        @treaty.errors.add(
          :base,
          "Please select a country to add."
        )
      end
    else
      # Remove buttons submit a value such as "remove:3".
      country_id = params[:country_action].split(":").last.to_i

      # Keep every selection except the country being removed.
      @treaty.country_ids = @treaty.country_ids.reject do |id|
        id == country_id
      end
    end
  end

  def form_response_status
    # Return an error status when the country selection is invalid.
    @treaty.errors.any? ? :unprocessable_entity : :ok
  end

  def treaty_params
    # Only allow editable treaty fields and an array of country IDs.
    params.require(:treaty).permit(
      :name,
      :date_signed,
      :status,
      :description,
      country_ids: []
    )
  end
end