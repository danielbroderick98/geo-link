class Admin::CountriesController < ApplicationController
  before_action :set_country, only: [:edit, :update]

  def index
    @country = Country.new
    @countries = Country.order(:name)
  end

  def create
    @country = Country.new(country_params)

    if @country.save
      redirect_to admin_countries_path,
                  notice: "Country added successfully.",
                  status: :see_other
    else
      @countries = Country.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    # @country is loaded by set_country.
  end

  def update
    if @country.update(country_params)
      redirect_to admin_countries_path,
                  notice: "Country updated successfully.",
                  status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_country
    @country = Country.find(params[:id])
  end

  def country_params
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