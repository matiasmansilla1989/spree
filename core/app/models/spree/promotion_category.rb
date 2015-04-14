module Spree
  class PromotionCategory < Spree::Base
    include MultiStore
    
    validates_presence_of :name
    belongs_to :store
    has_many :promotions
  end
end
