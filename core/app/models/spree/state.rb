module Spree
  class State < Spree::Base
    include MultiStore
    belongs_to :country, class_name: 'Spree::Country'
    has_many :addresses, dependent: :nullify
    belongs_to :store

    validates :country, :name, presence: true

    def self.find_all_by_name_or_abbr(name_or_abbr)
      where('name = ? OR abbr = ?', name_or_abbr, name_or_abbr)
    end

    # table of { country.id => [ state.id , state.name ] }, arrays sorted by name
    # blank is added elsewhere, if needed
    def self.states_group_by_country_id
      state_info = Hash.new { |h, k| h[k] = [] }
      self.order('name ASC').each { |state|
        state_info[state.country_id.to_s].push [state.id, state.name]
      }
      state_info
    end

    def <=>(other)
      name <=> other.name
    end

    def to_s
      name
    end
  end
end
