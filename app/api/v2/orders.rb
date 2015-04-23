module V2
  class Orders < Grape::API
    resources :orders do

      params do
        requires :phone, regexp: /^\d{11}$/, desc: "11位纯数字"
      end
      get "/" do
        orders = Order.where(phone_num: params[:phone])

        present :msg, ""
        present :code, 0
        present :data, orders, with: ::V2::Entities::Orders
      end

      params do
        requires :id
      end
      get "/:id" do
        order = Order.find(params[:id])
        raise ResourceNotFoundError unless order

        present :msg, ""
        present :code, 0
        present :data, order, with: ::V2::Entities::Order
      end
    end
  end
end