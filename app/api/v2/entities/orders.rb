module V2
  module Entities
    class Orders < BaseEntity
      expose :id
      expose :seq
      expose :order_state, as: :state
      expose :phone_num
      expose :commented
      expose :serve_datetime, format_with: :human_date
      expose :created_at, format_with: :human_date
      expose :calc_price, as: :total_price, format_with: :human_money
      expose :brand_logo
      expose :brand_name
      expose :model_name
      expose :model_engine_displacement
      expose :model_year_range
      expose :service_types, using: ::V2::Entities::ServiceType
      expose :parts, using: ::V2::Entities::Part
    end
  end
end