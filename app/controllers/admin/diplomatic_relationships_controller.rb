module Admin
    class DiplomaticRelationshipsController < ApplicationController
        # Find the saved relationship before editing, updating, or deleting it.
        before_action :set_diplomatic_relationship,
            only: [:edit, :update, :destroy]

        # Display all relationships and an empty form for adding a new one.
        def index
        load_relationships
        load_countries
        @diplomatic_relationship = DiplomaticRelationship.new
        end

        # Save a new diplomatic relationship.
        def create
        @diplomatic_relationship =
            DiplomaticRelationship.new(diplomatic_relationship_params)

        if @diplomatic_relationship.save
            redirect_to admin_diplomatic_relationships_path,
                notice: "Diplomatic relationship added successfully."
        else
            # Reload the page data and display any validation errors.
            load_relationships
            load_countries
            render :index, status: :unprocessable_entity
        end
        end

        # Display the form for editing an existing relationship.
        def edit
        load_countries
        end

        # Save changes to an existing relationship.
        def update
        if @diplomatic_relationship.update(diplomatic_relationship_params)
            redirect_to admin_diplomatic_relationships_path,
                notice: "Diplomatic relationship updated successfully."
        else
            # Keep the entered values and display validation errors.
            load_countries
            render :edit, status: :unprocessable_entity
        end
        end

        # Delete an existing relationship.
        def destroy
        if @diplomatic_relationship.destroy
            redirect_to admin_diplomatic_relationships_path,
                notice: "Diplomatic relationship deleted successfully.",
                status: :see_other
        else
            redirect_to admin_diplomatic_relationships_path,
                alert: @diplomatic_relationship.errors.full_messages.to_sentence,
                status: :see_other
        end
        end

        private

        # Find the relationship using the ID supplied in the URL.
        def set_diplomatic_relationship
        @diplomatic_relationship = DiplomaticRelationship.find(params[:id])
        end

        # Load relationships and their countries for the table.
        # Including the countries avoids separate database queries for each row.
        def load_relationships
        @diplomatic_relationships =
            DiplomaticRelationship.includes(:country_1, :country_2).order(:id)
        end

        # Load countries alphabetically for the form's dropdown menus.
        def load_countries
        @countries = Country.order(:name)
        end

        # Only allow these fields to be submitted through the form.
        def diplomatic_relationship_params
        params.require(:diplomatic_relationship).permit(
            :country_1_id,
            :country_2_id,
            :relationship_type
        )
        end
    end
end