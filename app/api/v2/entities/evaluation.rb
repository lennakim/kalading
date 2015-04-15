module V2
  module Entities
    class Evaluation < BaseEntity
      expose :id
      expose :desc, format_with: :null
      expose :score, format_with: :null
      expose :user_phone
      expose :created_at, format_with: :human_date
    end
  end
end