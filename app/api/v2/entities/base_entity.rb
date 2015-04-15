module V2
  module Entities
    class BaseEntity < Grape::Entity
      format_with(:null) {|v| v.blank? ? "" : v }
      format_with(:human_date) {|t| t.strftime("%Y-%m-%d %H:%M:%S") if t }

      format_with(:iso8601) {|t| t.iso8601 if t } # http://zh.wikipedia.org/wiki/ISO_8601
    end
  end
end
