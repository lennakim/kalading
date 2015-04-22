module V2
  class Orders < Grape::API
    resources :orders do

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