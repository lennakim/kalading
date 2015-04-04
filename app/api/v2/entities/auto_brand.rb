module V2
  module Entities
    class AutoBrand < BaseEntity
      expose :id
      expose :name
      expose :logo
      expose :name_pinyin
      expose :auto_models, using: ::V2::Entities::AutoModel
    end
  end
end
