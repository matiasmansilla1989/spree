module Spree
  class Store < Spree::Base
    validates :code, presence: true, uniqueness: { allow_blank: true }
    validates :name, presence: true
    validates :url, presence: true
    validates :mail_from_address, presence: true
    validates :subdomain, presence: true, uniqueness: true

    #### Multi Domain ####
    has_many   :admins,    :class_name => 'Spree::User', :foreign_key => 'store_admin_id'
    has_many   :customers, :class_name => 'Spree::User', :foreign_key => 'store_customer_id'
    has_many   :products, dependent: :destroy   
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
    has_many   :payment_methods, :class_name => 'Spree::PaymentMethod', inverse_of: :store
    has_many   :stock_locations, dependent: :destroy
    has_many   :stock_transfers
    has_many   :stock_items
    has_many   :variants
    has_many   :images
    has_many   :promotions
    has_many   :promotion_categories
    has_many   :return_authorization_reasons
    has_many   :return_authorizations
    #### Multi Domain ####

    before_save     :ensure_default_exists_and_is_unique, :set_url
    before_destroy  :validate_not_default
    after_create    :create_countries, :create_zones, :create_return_authorization_reasons


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

    def create_return_authorization_reasons
        Spree::ReturnAuthorizationReason.create!( name: 'Better price available', 
                                                  store_id: self.id )
        Spree::ReturnAuthorizationReason.create!( name: 'Missed estimated delivery date', 
                                                  store_id: self.id)
        Spree::ReturnAuthorizationReason.create!( name: 'Missing parts or accessories', 
                                                  store_id: self.id)
        Spree::ReturnAuthorizationReason.create!( name: 'Damaged/Defective', 
                                                  store_id: self.id)
        Spree::ReturnAuthorizationReason.create!( name: 'Different from what was ordered', 
                                                  store_id: self.id)
        Spree::ReturnAuthorizationReason.create!( name: 'Different from description', 
                                                  store_id: self.id)
        Spree::ReturnAuthorizationReason.create!( name: 'No longer needed/wanted', 
                                                  store_id: self.id)
        Spree::ReturnAuthorizationReason.create!( name: 'Accidental order', 
                                                  store_id: self.id)
        Spree::ReturnAuthorizationReason.create!( name: 'Unauthorized purchase', 
                                                  store_id: self.id)
    end

    def set_url
      if Rails.env.production?
        self.url = self.subdomain + '.webappbetaone.socialsquare.ae'
      else
        self.url = self.subdomain + '.socialsquare:3001'
      end
    end

  end


end
