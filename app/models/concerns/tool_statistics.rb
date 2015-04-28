module Concerns
  module ToolStatistics
    extend ActiveSupport::Concern

    # data:
    # [
    #   {
    #     "_id"=>{"city_id"=>"5307033e098e719c45000043", "tool_type_id"=>"550fde8a311f90ddbb000001"},
    #     "stock"=>98, "delivering"=>1, "assigned"=>0, "total"=>99
    #   },
    #   {...}
    # ]
    def self.statistics_to_objects(data)
      return [] if data.blank?

      # models_by_key:
      # {
      #   'city_id' => City,
      #   'tool_type_id' => ToolType
      # }
      models_by_key = {}
      data.first['_id'].each do |key, _|
        models_by_key[key] = key.gsub(/_id\Z/, '').camelize.constantize if key =~ /_id\Z/
      end

      # objs_by_id:
      # {
      #   'city_id-5307033e098e719c45000043' => city1,
      #   'tool_type_id-550fde8a311f90ddbb000001' => tool_type1,
      #   ...
      # }
      objs_by_id = {}
      data.each do |datum|
        datum['_id'].each do |key, id|
          objs_by_id["#{key}-#{id}"] ||= models_by_key[key].find(id) if key =~ /_id\Z/
        end
      end

      data.map do |datum|
        obj = OpenStruct.new
        datum['_id'].each do |key, id|
          obj[key.gsub(/_id\Z/, '')] = objs_by_id["#{key}-#{id}"]
          obj[key] = id
        end

        (datum.keys - ['_id']).each do |key|
          obj[key] = datum[key]
        end

        obj
      end
    end

  end
end
