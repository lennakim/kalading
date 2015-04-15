module V2
  class Evaluations < Grape::API
    helpers SharedParams

    resources :evaluations do
      params do
        requires :order_id
        optional :desc
        optional :score, type: Integer, default: 5
      end
      post "/" do
        order = Order.find(params[:order_id])
        raise ResourceNotFoundError unless order

        result = Evaluation.new(desc: params[:desc], score: params[:score], order: order).save
        status(200)  #设定http code为200 grape默认的 post 请求返回 201
        wrapper(result)
      end

      get "/" do
        result = Evaluation.recent.limit(10)

        present :msg, ""
        present :code, 0
        present :data, result, with: V2::Entities::Evaluation
      end
    end

  end
end