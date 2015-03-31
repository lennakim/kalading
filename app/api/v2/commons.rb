module V2
  class Commons < Grape::API
    helpers SharedParams

    resources :cities do
      get "/" do
        cities = City.all

        present :msg, ""
        present :code, 0
        present :data, cities, with: V2::Entities::City
      end
    end

    resources :autos do
      get "/" do
        @result = AutoBrand.group_by_name_pinyin
        present :data, @result, with: V2::Entities::Auto
      end
    end

  end
end
