# 出库，入库，盈余，损耗，调货的历史记录
class HistoryTracker
  include Mongoid::History::Tracker
  paginates_per 20
  
  # 统计出库历史
  def self.pb_to_part_delivered d1, d2
    map = %Q{
      function() {
        if(this.association_chain[0].name == "Partbatch") {
          if(this.original.remained_quantity != undefined && this.original.remained_quantity - this.modified.remained_quantity)
            emit(this.association_chain[0].id, {delivered: this.original.remained_quantity - this.modified.remained_quantity });
        }
      }
    }
    reduce = %Q{
      function(key, values) {
        var result = { delivered: 0 };
        values.forEach(function(value) {
          result.delivered += value.delivered;
        });
        return result;
      }
    }
    q = where(:created_at.gte => d1, :created_at.lt => d2)
    Hash[q.map_reduce(map, reduce).out(inline: 1).map { |data| [data['_id'].to_s, data['value']['delivered']] }]
  end
end
