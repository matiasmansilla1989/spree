module Spree
  module MultiStore
    extend ActiveSupport::Concern

    included do
      scope :filter_store, ->(store_id) { where("#{self.table_name}.store_id = ?", store_id) }  
    end

  end
end
