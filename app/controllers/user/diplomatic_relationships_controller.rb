# Display diplomatic relationships without allowing users to change them.
class User::DiplomaticRelationshipsController < ApplicationController
  def index
    # Preserve the submitted country-name search.
    @query = params[:query].to_s.strip

    # Build the filter from saved relationship types.
    # Types remain free text in the admin area.
    @relationship_types = DiplomaticRelationship
      .where.not(relationship_type: [nil, ""])
      .distinct
      .order(:relationship_type)
      .pluck(:relationship_type)

    # Accept only a type currently available in the dropdown.
    # An empty value means all types.
    @relationship_type = params[:relationship_type].to_s

    unless @relationship_types.include?(@relationship_type)
      @relationship_type = ""
    end

    # Load both countries with each relationship to avoid
    # separate country queries for every table row.
    @diplomatic_relationships = DiplomaticRelationship
      .includes(:country_1, :country_2)
      .order(:id)

    if @query.present?
      # Escape wildcard characters so they are treated as text.
      escaped_query = Country.sanitize_sql_like(@query.downcase)

      # Find country IDs whose names contain the search text.
      # This remains a database subquery rather than loading all IDs.
      matching_country_ids = Country
        .where("LOWER(name) LIKE ?", "%#{escaped_query}%")
        .select(:id)

      # Match the country in either position in a relationship.
      @diplomatic_relationships = @diplomatic_relationships
        .where(country_1_id: matching_country_ids)
        .or(
          @diplomatic_relationships.where(
            country_2_id: matching_country_ids
          )
        )
    end

    if @relationship_type.present?
      # Apply the type filter to the country-search results.
      @diplomatic_relationships = @diplomatic_relationships.where(
        relationship_type: @relationship_type
      )
    end
  end

  def show
    # Load the selected relationship and both countries.
    # Rails returns a 404 response if the record does not exist.
    @diplomatic_relationship = DiplomaticRelationship
      .includes(:country_1, :country_2)
      .find(params[:id])
  end
end