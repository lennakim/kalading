module V2
  class Commons < Grape::API
    helpers SharedParams

    resources :cities do
      get "/" do
        cities = City.all
        present cities, with: V2::Entities::City
      end
    end
  end
end