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
        present :msg, ""
        present :code, 0
        present :data, @result, with: V2::Entities::Auto
      end

      params do
        requires :id
      end
      get "/:id" do
        auto_brand = AutoBrand.find(params[:id])
        raise ResourceNotFoundError unless auto_brand

        result = auto_brand.auto_models

        present :msg, ""
        present :code, 0
        present :data, result, with: V2::Entities::AutoModel
      end
    end

  end
end
