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
    has_many   :countries
    has_many   :zones
    has_many   :tax_rates
    has_many   :tax_categories
    has_many   :states
    has_many   :payment_methods, :class_name => 'Spree::PaymentMethod'
    has_many   :stock_locations
    has_many   :stock_transfers
    has_many   :stock_items
    has_many   :variants
    has_many   :images
    has_many   :promotions
    has_many   :promotion_categories
    #### Multi Domain ####

    before_save :ensure_default_exists_and_is_unique
    before_destroy :validate_not_default
    after_create :create_countries, :create_zones

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

    def create_countries
      require 'carmen'

      countries = []
      Carmen::Country.all.each do |country|
        countries << {
          name: country.name,
          iso3: country.alpha_3_code,
          iso: country.alpha_2_code,
          iso_name: country.name.upcase,
          numcode: country.numeric_code,
          states_required: country.subregions?,
          store_id: self.id
        }
      end

      ActiveRecord::Base.transaction do
        Spree::Country.create!(countries)
      end
    end

    def create_zones
      eu_vat = Spree::Zone.create!(name: "EU_VAT", 
        description: "Countries that make up the EU VAT zone.", store_id: self.id)
      north_america = Spree::Zone.create!(name: "North America", 
        description: "USA + Canada", store_id: self.id)

      ["Poland", "Finland", "Portugal", "Romania", "Germany", "France",
       "Slovakia", "Hungary", "Slovenia", "Ireland", "Austria", "Spain",
       "Italy", "Belgium", "Sweden", "Latvia", "Bulgaria", "United Kingdom",
       "Lithuania", "Cyprus", "Luxembourg", "Malta", "Denmark", "Netherlands",
       "Estonia"].
      each do |name|
        eu_vat.zone_members.create!(zoneable: Spree::Country.find_by!(name: name))
      end

      ["United States", "Canada"].each do |name|
        north_america.zone_members.create!(zoneable: Spree::Country.find_by!(name: name))
      end
    end
  end


end
