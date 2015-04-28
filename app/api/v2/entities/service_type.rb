module V2
  module Entities
    class ServiceType < BaseEntity
      expose :name
      expose :price, format_with: :human_money
    end
  end
end
