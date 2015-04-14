module Spree
  class Property < Spree::Base
    include MultiStore
    has_and_belongs_to_many :prototypes, join_table: 'spree_properties_prototypes'

    has_many :product_properties, dependent: :delete_all, inverse_of: :property
    has_many :products, through: :product_properties

    validates :name, :presentation, presence: true

    scope :sorted, -> { order(:name) }

    after_touch :touch_all_products

    #### Admin User ####
    belongs_to :user, class_name: 'Spree::User'
    #### Admin User ####

    ### Multi Domain ###
    belongs_to :store
    ### Multi Domain ###

    private

    def touch_all_products
      products.update_all(updated_at: Time.current)
    end
  end
end
