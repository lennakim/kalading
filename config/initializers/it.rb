ActionController::Responder.class_eval do
  alias :to_mobile :to_html
end

Mongoid::History.tracker_class_name = :history_tracker
Mongoid::History.current_user_method = :current_operator

require_dependency 'history_tracker.rb' if Rails.env == "development"