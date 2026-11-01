# Display treaty information without allowing users to change it.
class User::TreatiesController < ApplicationController
  def index
    # Preserve the submitted treaty-name search.
    @query = params[:query].to_s.strip

    # Populate the status filter using values entered by admins.
    # This keeps status as free text in the admin area.
    @statuses = Treaty
      .where.not(status: [nil, ""])
      .distinct
      .order(:status)
      .pluck(:status)

    # Accept only a status available in the dropdown.
    # An empty value means all statuses.
    @status = params[:status].to_s
    @status = "" unless @statuses.include?(@status)

    # Load participating countries alongside treaties.
    # This avoids a separate country query for each table row.
    @treaties = Treaty.includes(:countries).order(:name, :id)

    if @query.present?
      # Escape wildcard characters so they are searched as text.
      escaped_query = Treaty.sanitize_sql_like(@query.downcase)

      # Match treaty names containing the entered text.
      # The placeholder keeps user input separate from the SQL.
      @treaties = @treaties.where(
        "LOWER(name) LIKE ?",
        "%#{escaped_query}%"
      )
    end

    if @status.present?
      # Apply the status filter to the name-search results.
      @treaties = @treaties.where(status: @status)
    end
  end

  def show
    # Load the selected treaty and its participating countries.
    # Rails returns a 404 response if the treaty does not exist.
    @treaty = Treaty.includes(:countries).find(params[:id])
  end
end