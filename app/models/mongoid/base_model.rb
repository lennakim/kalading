# 基本 Model, 加入一些通用功能
module Mongoid
  module BaseModel
    extend ActiveSupport::Concern

    included do
      scope :recent, -> { desc(:create_at) }
    end

    module ClassMethods

      # search 方法名比较常见, 可能会有冲突
      def _search_(k, v)
        if k && v && v.size > 0
          any_of({ k => /.*#{v}.*/i })
        else
          all
        end
      end

    end
  end
end
