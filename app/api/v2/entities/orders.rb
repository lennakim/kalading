module V2
  module Entities
    class Orders < BaseEntity
      expose :id
      expose :seq
      expose :order_state, as: :state
      expose :phone_num
      expose :evaluated
      expose :serve_datetime, format_with: :human_date
      expose :created_at, format_with: :human_date
      expose :calc_price, as: :total_price, format_with: :human_money
      expose :brand_logo format_with: :null
      expose :brand_name
      expose :model_name
      expose :model_engine_displacement
      expose :model_year_range
      expose :services_desc
      expose :need_online_pay
      expose :parts_detail, as: :parts
      expose :calc_service_price, as: :service_price, format_with: :human_money
      expose :service_types, using: ::V2::Entities::ServiceType
    end
  end
end
