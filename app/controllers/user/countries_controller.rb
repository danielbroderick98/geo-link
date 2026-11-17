# Display read-only country information in the user area.
class User::CountriesController < ApplicationController
  def index
    # Preserve the search text for the form.
    @query = params[:query].to_s.strip

    # Accept only recognised status filters.
    # An empty value means all countries.
    @status = params[:status].to_s
    @status = "" unless %w[active inactive].include?(@status)

    # Start with all countries in alphabetical order.
    @countries = Country.order(:name)

    if @query.present?
      # Treat special search characters as ordinary text.
      escaped_query = Country.sanitize_sql_like(@query.downcase)

      # Search for names containing the entered text.
      # Bind the entered text separately so it is used as a search value.
      @countries = @countries.where(
        "LOWER(name) LIKE ?",
        "%#{escaped_query}%"
      )
    end

    # Apply the status filter to the search results.
    case @status
    when "active"
      @countries = @countries.where(active: true)
    when "inactive"
      # Include older records with an unset status because the
      # existing views also display these as inactive.
      @countries = @countries.where(active: [false, nil])
    end
  end

  def show
    # Load the selected country.
    # Rails returns a 404 response if it does not exist.
    @country = Country.find(params[:id])
    # Only pass this country's linked records to the timeline library.
    @timeline = GeoLink::CountryTimeline.build(
      treaties: @country.treaties,
      events: @country.geopolitical_events
    )
  end
end