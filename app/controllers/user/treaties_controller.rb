# Display treaty information in the public directory.
class User::TreatiesController < ApplicationController
  SORT_OPTIONS = [
    [ "Name (A–Z)", "name asc" ],
    [ "Name (Z–A)", "name desc" ],
    [ "Signing date (newest first)", "date_signed desc" ],
    [ "Signing date (oldest first)", "date_signed asc" ]
  ].freeze

  def index
    # Use saved statuses so new values entered by admins appear in the dropdown.
    @statuses = Treaty.where.not(status: [ nil, "" ]).distinct.order(:status).pluck(:status)
    search = treaty_search_params

    # Keep older bookmarked URLs working alongside the new Ransack form.
    @query = (search[:name_i_cont] || params[:query]).to_s.strip
    @status = (search[:status_eq] || params[:status]).to_s
    @status = "" unless @statuses.include?(@status)

    @search_errors = []
    @signed_from = signing_date(search[:date_signed_gteq], "from")
    @signed_until = signing_date(search[:date_signed_lteq], "until")
    if @signed_from && @signed_until && @signed_until < @signed_from
      @search_errors << "The signing date until must be on or after the signing date from."
    end

    # Accept the same sort choices as the form, including when a URL is edited by hand.
    @sort_options = SORT_OPTIONS
    @sort = search[:s].to_s
    @sort = "name asc" unless SORT_OPTIONS.map(&:last).include?(@sort)

    # Ransack combines these conditions with AND. Date boundaries include the selected day.
    # Preserve saved status text exactly. The name search has already been trimmed above.
    @q = Treaty.ransack({
      name_i_cont: @query,
      status_eq: @status,
      date_signed_gteq: @signed_from,
      date_signed_lteq: @signed_until
    }, strip_whitespace: false)
    @q.sorts = @sort

    # Load countries with the results and use the ID to settle ties in the chosen sort.
    @treaties = @q.result.includes(:countries).order(:id)
    @filters_active = [ @query, @status, @signed_from, @signed_until ].any?(&:present?) ||
      @sort != "name asc" || @search_errors.any?

    # Keep the form visible when a date needs correcting, with no partial search results.
    if @search_errors.any?
      @treaties = @treaties.none
      render :index, status: :unprocessable_entity
    end
  end

  def show
    # Load participating countries with the treaty for the public detail page.
    @treaty = Treaty.includes(:countries).find(params[:id])
  end

  private

  def treaty_search_params
    # Permit just the comparisons used by this form, including its single sort choice.
    search = params[:q]
    return {} unless search.is_a?(ActionController::Parameters)

    search.permit(:name_i_cont, :status_eq, :date_signed_gteq, :date_signed_lteq, :s)
  end

  def signing_date(value, boundary)
    return if value.blank?

    # Parse the browser's date format explicitly so an invalid date cannot broaden the search.
    raise Date::Error unless value.match?(/\A\d{4}-\d{2}-\d{2}\z/)

    Date.iso8601(value).iso8601
  rescue Date::Error
    @search_errors << "Enter a valid signing date #{boundary}."
    nil
  end
end
