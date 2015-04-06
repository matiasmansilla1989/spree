module Spree
  class Store < Spree::Base
    validates :code, presence: true, uniqueness: { allow_blank: true }
    validates :name, presence: true
    validates :url, presence: true
    validates :mail_from_address, presence: true

    #### Multi Domain ####
    belongs_to :user, :class_name => 'Spree::User'
    has_many   :customers, :class_name => 'Spree::User', :foreign_key => 'store_customer_id'
    has_many   :products   
    has_many   :option_types
    has_many   :properties 
    has_many   :taxons
    has_many   :prototypes   
    has_many   :shipping_methods
    has_many   :shipping_categories  
    has_many   :users
    #### Multi Domain ####

    before_save :ensure_default_exists_and_is_unique
    before_destroy :validate_not_default

    scope :by_url, lambda { |url| where("url like ?", "%#{url}%") }

    def self.current(domain = nil)
      current_store = domain ? Store.by_url(domain).first : nil
      current_store || Store.default
    end

    def self.default
      where(default: true).first || new
    end

    private

    def ensure_default_exists_and_is_unique
      if default
        Store.where.not(id: id).update_all(default: false)
      elsif Store.where(default: true).count == 0
        self.default = true
      end
    end

    def validate_not_default
      if default
        errors.add(:base, :cannot_destroy_default_store)
      end
    end
  end
end
