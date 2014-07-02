class HistoryTracker
  include Mongoid::History::Tracker
  paginates_per 20
end
