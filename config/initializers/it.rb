ActionController::Responder.class_eval do
  alias :to_mobile :to_html
end

Mongoid::History.tracker_class_name = :history_tracker
Mongoid::History.modifier_class_name = "Order"
Mongoid::History.current_user_method = :current_order

require_dependency 'history_tracker.rb' if Rails.env == "development"