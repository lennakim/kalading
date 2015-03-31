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

      get "/autos" do
        @result = AutoBrand.group_by_name_pinyin
        present :data, @result, with: V2::Entities::Auto
      end

      get "/auto_brands" do
        auto_brands = AutoBrand.all

        present :msg, ""
        present :code, 0
        present :data, auto_brands, with: V2::Entities::AutoBrand
      end

      params do
        requires :auto_brand_id
      end
      get "/auto_brands/:auto_brand_id/auto_models" do
        auto_models = AutoModel.where(auto_brand_id: params[:auto_brand_id])

        present :msg, ""
        present :code, 0
        present :data, auto_models, with: V2::Entities::AutoModel
      end

      params do
        requires :auto_model_id
      end
      get "/auto_models/:auto_model_id/auto_submodels" do
        auto_submodels = AutoSubmodel.where(auto_model_id: params[:auto_model_id])

        present :msg, ""
        present :code, 0
        present :data, auto_submodels, with: V2::Entities::AutoSubmodel
      end
  end
end
