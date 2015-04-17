module Spree
  class ReturnAuthorizationReason < Spree::Base
    include MultiStore
    include Spree::NamedType

    belongs_to  :store
    has_many    :return_authorizations
  
  end
end
