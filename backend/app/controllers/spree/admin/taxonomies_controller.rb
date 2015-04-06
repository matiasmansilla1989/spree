module Spree
  module Admin
    class TaxonomiesController < ResourceController
      # before_action :filter_taxonomies, :only => [:index]
      respond_to :json, :only => [:get_children]

      def get_children
        @taxons = Taxon.find(params[:parent_id]).children
      end

      private

      def location_after_save
        if @taxonomy.created_at == @taxonomy.updated_at
          edit_admin_taxonomy_url(@taxonomy)
        else
          admin_taxonomies_url
        end
      end

      # def filter_taxonomies
      #   @collection = @collection.where(user_id: spree_current_user.id)
      #   @collection
      # end
    end
  end
end
