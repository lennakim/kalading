module V2
  module Entities
    class Part < BaseEntity
      expose :part_brand_name
      expose :number
      expose :price, format_with: :human_money
    end
  end
end
