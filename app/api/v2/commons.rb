module V2
  class Commons < Grape::API
    helpers SharedParams

    resources :cities do
      get "/" do
        @cities = City.all
        # wrapper(@apps)
        @cities
      end
    end
  end
end