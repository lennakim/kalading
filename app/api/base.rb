class Base < Grape::API
  mount V2::API
end