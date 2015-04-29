# 出库，入库，盈余，损耗，调货的历史记录
class HistoryTracker
  include Mongoid::History::Tracker
  include Mongoid::Userstamp
  mongoid_userstamp user_model: 'User'
  paginates_per 5
end
