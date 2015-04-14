module Spree
  class ShippingCategory < Spree::Base
    include MultiStore
    validates   :name, presence: true
    belongs_to  :store
    has_many    :products, inverse_of: :shipping_category
    has_many    :shipping_method_categories, inverse_of: :shipping_category
    has_many    :shipping_methods, through: :shipping_method_categories
  end
end
