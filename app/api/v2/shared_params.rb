module V2
  module SharedParams
    extend Grape::API::Helpers

    params :paginate do
      optional :page,    type: Integer, default: 1,  desc: 'Page Num. Default value is 1'
      optional :per_num, type: Integer, default: 10, desc: 'Per Num.  Default value is 10'
    end
  end
end