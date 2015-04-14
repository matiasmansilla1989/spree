module Spree
  module Admin
    class TaxRatesController < ResourceController
      before_action :load_data

      private

      def load_data
        @available_zones = Zone.order(:name).filter_store(current_store.id)
        @available_categories = TaxCategory.order(:name).filter_store(current_store.id)
        @calculators = TaxRate.calculators.sort_by(&:name)
      end
    end
  end
end
