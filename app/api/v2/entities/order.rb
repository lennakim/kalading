module V2
  module Entities
    class Order < BaseEntity
      expose :id
      expose :seq
      expose :order_state, as: :state
      expose :name
      expose :phone_num
      expose :address
      expose :commented
      expose :created_at, format_with: :human_date
      expose :serve_datetime, format_with: :human_date
      expose :order_pay_type, as: :pay_type
      expose :calc_price, as: :total_price, format_with: :human_money
      expose :license_plate
      expose :brand_name
      expose :model_name
      expose :model_engine_displacement
      expose :model_year_range
      expose :service_types, using: ::V2::Entities::ServiceType
      expose :parts, using: ::V2::Entities::Part
      expose :engineer, using: ::V2::Entities::Engineer
    end
  end
end