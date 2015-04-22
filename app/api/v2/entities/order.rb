module V2
  module Entities
    class Order < BaseEntity
      expose :id
      expose :state
      expose :name
      expose :phone_num
      expose :address
      expose :serve_datetime, format_with: :human_date
      expose :pay_type
      expose :car_info
      expose :model_info
      expose :engineer, using: ::V2::Entities::Engineer
    end
  end
end
