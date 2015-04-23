module V2
  module Entities
    class Orders < BaseEntity
      expose :id
      expose :seq
      expose :order_state, as: :state
      expose :phone_num
      expose :brand_logo
      expose :serve_datetime, format_with: :human_date
      expose :calc_price, as: :total_price, format_with: :human_money
      expose :parts, using: ::V2::Entities::Part
    end
  end
end
