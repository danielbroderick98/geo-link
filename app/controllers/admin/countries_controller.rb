class Admin::CountriesController < ApplicationController
  def index
    # Prepare an empty country for the form beside the table.
    @country = Country.new

    # Load countries using the search and status filters.
    load_countries
  end

  def new
    # The add-country form is displayed on the management page.
    redirect_to admin_countries_path
  end

  def create
    # Build a country using the permitted form fields.
    @country = Country.new(country_params)

    if @country.save
      redirect_to admin_countries_path,
                  notice: "Country added successfully."
    else
      # Reload the table while preserving the entered details
      # and validation errors in @country.
      load_countries
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    # Load the country into the existing edit page.
    @country = Country.find(params[:id])
  end

  def update
    @country = Country.find(params[:id])

    if @country.update(country_params)
      redirect_to admin_countries_path,
                  notice: "Country updated successfully.",
                  status: :see_other
    else
      # Keep the entered details and display validation errors.
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @country = Country.find(params[:id])

    # Roll back associated deletions if a linked record
    # prevents the country from being deleted.
    Country.transaction do
      @country.destroy!
    end

    redirect_to admin_countries_path,
                notice: "Country deleted successfully.",
                status: :see_other
  rescue ActiveRecord::DeleteRestrictionError,
         ActiveRecord::InvalidForeignKey,
         ActiveRecord::RecordNotDestroyed
    # Display a helpful message if deletion is blocked.
    redirect_to admin_countries_path,
                alert: "This country could not be deleted. Check its linked records.",
                status: :see_other
  end

  private

  def load_countries
    # Keep the filter values available to the search form.
    @query = params[:query].to_s.strip
    @status = params[:status].to_s

    # Start with all countries in alphabetical order.
    @countries = Country.order(:name)

    if @query.present?
      # Escape wildcard characters so they are treated as search text.
      search = "%#{Country.sanitize_sql_like(@query.downcase)}%"

      # Search country names and regions without matching letter case.
      # Named parameters keep the submitted value out of the SQL itself.
      @countries = @countries.where(
        "LOWER(name) LIKE :search OR LOWER(region) LIKE :search",
        search: search
      )
    end

    # Filter by the Boolean active field.
    # An empty status leaves both active and inactive countries visible.
    case @status
    when "active"
      @countries = @countries.where(active: true)
    when "inactive"
      @countries = @countries.where(active: false)
    end
  end

  def country_params
    # Only allow editable country fields from the form.
    # Rails assigns the ID and timestamps automatically.
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