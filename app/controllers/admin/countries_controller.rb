class Admin::CountriesController < ApplicationController
  def index
    # Build an empty country for the form and load saved countries.
    @country = Country.new
    @countries = Country.order(:name)
  end

  def create
    @country = Country.new(country_params)

    if @country.save
      # Redirect after saving so refreshing does not repeat the submission.
      redirect_to admin_countries_path,
                  notice: "Country added successfully.",
                  status: :see_other
    else
      # Reload the list and show the form with its validation errors.
      @countries = Country.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def country_params
    # Only allow the fields that belong to a country.
    params.require(:country).permit(
      :name,
      :region,
      :capital,
      :population,
      :political_system,
      :active
    )
  end
end
