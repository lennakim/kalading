class Engineer < User
  include Mongoid::Document

  paginates_per 15

  field :roles, type: Array, default: ["5"]

  LEVEL_STR = %w-养护技师 高级养护技师 资深养护技师 首席养护技师-
  field :level, type: Integer, default: 0

  STATUS_STR = %w-可派 不可派-
  field :status, type: Integer, default: 0

  # 工牌 TODO 7位
  field :work_tag_number, type: String
  # TODO：目前技师的工牌都是空，导致update_realtime_info 抛出validation error
  #validates :work_tag_number, uniqueness: true, length: { minimum: 7, maximum: 7 }

  # 所配车辆 TODO
  #

  # 培训技能

  attr_accessible :work_tag_number

  class << self
    # migrate所有角色为技师的User的type为Engineer, 用完可以删除
    def migrate_user_to_engineer
      User.where(roles: "5").update_all _type: 'Engineer'
    end
  end

  # pm25_orders
  # maintain_orders
  # detection_orders
  ["pm25", "maintain", "detection"].each do |order_type|
    define_method "#{order_type}_orders" do
      id = ServiceType.where(name: I18n.t("service_#{order_type}")).pluck(:id)
      serve_orders.where(service_type_ids: id)
    end
  end

  def service_orders_count
    map = %Q{
      function() {
        this.service_type_ids.forEach(function(service_type_id){
          emit(service_type_id, 1);
        });
      }
    }
    reduce = %Q{
      function(key, values) {
        return Array.sum(values);
      }
    }

    serve_orders.valid.from_this_month.map_reduce(map, reduce).out(inline: true)
  end

  def status_str
    STATUS_STR[status]
  end

  def level_str
    LEVEL_STR[level]
  end

end
