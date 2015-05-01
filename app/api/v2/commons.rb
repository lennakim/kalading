module V2
  class Commons < Grape::API
    helpers SharedParams

    resources :cities do
      get "/" do
        cities = City.without_auto_submodels

        present :msg, ""
        present :code, 0
        present :data, cities, with: V2::Entities::City
      end

      params do
        requires :id
        optional :start_at, :end_at
      end
      get ":id/capacity" do
        city = City.find(params[:id])

        start_at = Date.parse params[:start_at] if params[:start_at]
        end_at = Date.parse params[:end_at] if params[:end_at]

        result = city.capacity(start_at , end_at)
        wrapper(result)
      end
    end

    resources :autos do
      get "/" do
        @result = AutoBrand.group_by_name_pinyin
        present :msg, ""
        present :code, 0
        present :data, @result, with: V2::Entities::Auto
      end
    end

      params do
        requires :id
      end
      get "auto_models/:id" do
        auto_model = AutoModel.find(params[:id])
        raise ResourceNotFoundError unless auto_model
        result = auto_model.auto_submodels.group_by_engine_displacement

        present :msg, ""
        present :code, 0
        present :data, result, with: ::V2::Entities::Submodel
      end
      
    get "/haiwanshiyou_remain_capacity" do
      user_type = UserType.find_by(name: I18n.t(:haiwanshiyou))
      orders = Order.where(:user_type => user_type, :created_at.gte => Date.today.beginning_of_day, :created_at.lte => Date.today.end_of_day).not_in(state: [1, 8, 10])
      if orders.size >= 50 
        present :msg, I18n.t(:haiwanshiyou_orders_out_tip)
        present :code, 3001
      else
        present :msg, ""
        present :code, 0
      end
    end
  end
end
