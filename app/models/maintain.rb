# 保养记录
class Maintain
  include Mongoid::Document
  include Mongoid::Timestamps

  # 外观描述
  field :outlook_desc, type: String, default: ""
  # 购买日期
  field :buy_date, type: Date
  # VIN号
  field :VIN, type: String, default: ""
  # 保险日期
  field :insurance_date, type: String, default: ""
  # 颜色
  field :auto_color, type: String, default: ""
  # 发动机号
  field :engine_num, type: String, default: ""
  # 机油尺位置
  field :oil_position, type: Integer, default: 1
  # 放出机油量
  field :oil_out, type: Float, default: 0
  # 注入机油量
  field :oil_in, type: Float, default: 0
  # 机油描述
  field :oil_desc, type: Integer, default: 0
  # 是否采集了机油小样
  field :oil_sample_collected, type: Boolean, default: false
  # 机油小样毫升
  field :oil_sample_number, type: Integer, default: 0
  # 是否换了机滤
  field :oil_filter_changed, type: Boolean, default: false
  # 为啥没换机滤
  field :oil_filter_not_changed_reason, type: String, default: ""
  # 空气滤描述
  field :air_filter_desc, type: Integer, default: 0
  # 是否换了空气滤
  field :air_filter_changed, type: Boolean, default: false
  # 为啥没换空气滤
  field :air_filter_not_changed_reason, type: String, default: ""
  # 空调滤描述
  field :cabin_filter_desc, type: Integer, default: 0
  # 是否换了空调滤
  field :cabin_filter_changed, type: Boolean, default: false
  # 为啥没换空调滤
  field :cabin_filter_not_changed_reason, type: String, default: ""
  # 刹车油描述
  field :brake_oil_desc, type: Integer , default: 0
  # 刹车油沸点
  field :brake_oil_boiling_point, type: Integer, default: 0
  # 刹车油尺位置
  field :brake_oil_position, type: Integer , default: 0
  # 防冻液描述
  field :antifreeze_desc, type: Integer, default: 0
  # 防冻液冰点
  field :antifreeze_freezing_point, type: Integer, default: 0
  # 防冻液位置
  field :antifreeze_position, type: Integer, default: 0
  # 防冻液颜色
  field :antifreeze_color, type: String, default: ""
  # 转向油描述
  field :steering_oil_desc, type: Integer, default: 0
  # 转向油位置
  field :steering_oil_position, type: Integer, default: 0
  # 变速箱油描述
  field :gearbox_oil_desc, type: Integer, default: 0
  # 变速箱油位置
  field :gearbox_oil_position, type: Integer, default: 0
  # 玻璃水描述
  field :glass_water_desc, type: Integer, default: 0
  # 玻璃水是否添加
  field :glass_water_add, type: Boolean, default: false
  # 玻璃水添加数量
  field :glass_water_amount, type: Integer, default: 0
  # 电瓶...
  field :battery_desc, type: Integer, default: 0
  field :battery_charge, type: String, default: ""
  field :battery_health, type: String, default: ""
  field :battery_light_color, type: String, default: ""
  field :battery_head_desc, type: Integer, default: 0
  field :engine_hose_and_line_desc, type: Integer, default: 0
  # 雨刷
  field :front_wiper_desc, type: Integer, default: 0
  field :back_wiper_desc, type: Integer, default: 0
  field :extinguisher_desc, type: Integer, default: 0
  field :warning_board_desc, type: Integer, default: 0
  field :spare_tire_desc, type: Integer, default: 0
  # 是否保养归零
  field :km_be_zero, type: Boolean, default: false
  # 上次里程
  field :last_km, type: String, default: ""
  #当前里程
  field :curr_km, type: String, default: ""
  #下次保养里程
  field :next_maintain_km, type: String, default: ""
  # 备注
  field :comment, type: String, default: ""
  # 保养花费时间，由app计算
  field :total_time, type: Integer, default: 0
  # 属于订单
  belongs_to :order

  POSITION_STRINGS = %w[high middle low undetectable]
  OIL_STRINGS = %w[muddy dirty serious_dirty]
  OTHER_OIL_STRINGS = %w[clean muddy dirty undetectable]
  FILTER_STRINGS = %w[clean dirty serious_dirty]
  GLASS_WATER_STRINGS = %w[full lack]
  BATTERY_STRINGS = %w[good worn leak undetectable]
  BATTERY_HEAD_STRINGS = %w[good corroded undetectable]
  BATTERY_LIGHT_COLOR_STRINGS = %w[green black white]
  ENGINE_HOSE_AND_LINE_STRINGS = %w[normal slight serious]
  WIPER_STRINGS = %w[normal recommend_replace none]
  AUTO_TOOLS_STRINGS = %w[existed not_existed undetected]

  # desc and position same score
  OIL_SCORE = [1,2,0]
  ANTIFREEZE_SCORE = [2,1,0]
  OTHER_OIL_SCORE = [1,0.5,0,1]

  BRAKE_OIL_SCORE = [2,1,0,0]
  BRAKE_OIL_POSITION_SCORE = [3,2,1,0]
  FILTER_SCORE = [1,1,0]
  GLASS_WATER_SCORE = [1,0]
  BATTERY_SCORE = [1,0.5,0,1]
  BATTERY_HEAD_SCORE = [1,0,1]
  FRONT_WIPER_SCORE = [2,0]
  BACK_WIPER_SCORE = [1,0,1]
  AUTO_TOOLS_SCORE = [2,0,2]
  BRAKE_OIL_POINT_SCORE = {0..2 => 4, 2..3 => 3, 3..4 => 1}
  ANTIFREEZE_POINT_SCORE = {-100..-35 => 3, -35..-10 => 1}
  BATTERY_HEALTH_SCORE = {60..70 => 1, 70..90 => 2, 90..100 => 3}
  BATTERY_CHARGE_SCORE = {60..90 => 1, 90..100 => 2}

  embeds_many :wheels, :cascade_callbacks => true
  embeds_many :lights, :cascade_callbacks => true
  embeds_many :outlook_pics, class_name: "Picture"
  embeds_many :oil_pics, class_name: "Picture"
  embeds_many :air_filter_pics, class_name: "Picture"
  embeds_many :cabin_filter_pics, class_name: "Picture"
  embeds_many :tire_left_front_pics, class_name: "Picture"
  embeds_many :tire_left_back_pics, class_name: "Picture"
  embeds_many :tire_right_front_pics, class_name: "Picture"
  embeds_many :tire_right_back_pics, class_name: "Picture"
  embeds_many :tire_spare_pics, class_name: "Picture"
  embeds_many :oil_and_battery_pics, class_name: "Picture"


  accepts_nested_attributes_for :wheels, :allow_destroy => true
  accepts_nested_attributes_for :lights, :allow_destroy => true
  accepts_nested_attributes_for :outlook_pics, :allow_destroy => true
  accepts_nested_attributes_for :oil_pics, :allow_destroy => true
  accepts_nested_attributes_for :air_filter_pics, :allow_destroy => true
  accepts_nested_attributes_for :cabin_filter_pics, :allow_destroy => true
  accepts_nested_attributes_for :tire_left_front_pics, :allow_destroy => true
  accepts_nested_attributes_for :tire_left_back_pics, :allow_destroy => true
  accepts_nested_attributes_for :tire_right_front_pics, :allow_destroy => true
  accepts_nested_attributes_for :tire_right_back_pics, :allow_destroy => true
  accepts_nested_attributes_for :tire_spare_pics, :allow_destroy => true
  accepts_nested_attributes_for :oil_and_battery_pics, :allow_destroy => true

  attr_accessible :outlook_desc, :buy_date, :VIN, :insurance_date, :auto_color, :engine_num,
    :oil_position, :oil_out, :oil_in, :oil_desc, :oil_sample_collected, :oil_sample_number,
    :oil_filter_changed, :oil_filter_not_changed_reason,
    :air_filter_desc, :air_filter_changed, :air_filter_not_changed_reason,
    :cabin_filter_desc, :cabin_filter_changed, :cabin_filter_not_changed_reason,
    :brake_oil_desc, :brake_oil_boiling_point, :brake_oil_position, :antifreeze_desc, :antifreeze_freezing_point,
    :antifreeze_position, :antifreeze_color, :steering_oil_desc, :steering_oil_position, :gearbox_oil_desc,
    :gearbox_oil_position, :glass_water_desc, :glass_water_add, :glass_water_amount,
    :battery_charge, :battery_health, :battery_desc, :battery_light_color, :battery_head_desc,
    :front_wiper_desc, :back_wiper_desc, :extinguisher_desc, :warning_board_desc, :spare_tire_desc,
    :km_be_zero, :curr_km, :last_km, :next_maintain_km, :comment, :total_time, :engine_hose_and_line_desc,
    :wheel_ids, :wheels_attributes, :light_ids, :lights_attributes,:order_id

  # 保养评分
  def calc_score(type)
    score = 0.0
    if type == "wheels_brake"
      self.wheels.each do |w|
        score += w.score
      end
      if self.spare_tire_desc == 1
        score += -2
      end
      BRAKE_OIL_POINT_SCORE.each do |k, v|
        if k.include? self.brake_oil_boiling_point
          score += v
          break
        end
      end
      score += BRAKE_OIL_SCORE[self.brake_oil_desc]
      score += BRAKE_OIL_POSITION_SCORE[self.brake_oil_position]
    end

    if type == "lights"
      self.lights.each do |l|
        score += l.score
      end
    end

    if type == "filter_oil_battery"
      score += (OIL_SCORE[self.oil_desc] + OIL_SCORE[self.oil_position])
      score += (ANTIFREEZE_SCORE[self.antifreeze_desc] + ANTIFREEZE_SCORE[self.antifreeze_position])
      score += (OTHER_OIL_SCORE[self.steering_oil_desc] + OTHER_OIL_SCORE[self.steering_oil_position])
      score += (OTHER_OIL_SCORE[self.gearbox_oil_desc] + OTHER_OIL_SCORE[self.gearbox_oil_position])
      score += (FILTER_SCORE[self.air_filter_desc] + FILTER_SCORE[self.cabin_filter_desc])
      score += GLASS_WATER_SCORE[self.glass_water_desc]
      score += BATTERY_SCORE[self.battery_desc]
      score += BATTERY_HEAD_SCORE[self.battery_head_desc]
      ANTIFREEZE_POINT_SCORE.each do |k, v|
        if k.include? self.antifreeze_freezing_point
          score += v
          break
        end
      end
      case self.battery_light_color
      when "green"
        score += 1
      when "black", "white"
        score += 0.5
      end

      BATTERY_HEALTH_SCORE.each do |k, v|
        if k.include? self.battery_health.to_i
          score += v
          break
        end
      end
      BATTERY_CHARGE_SCORE.each do |k, v|
        if k.include? self.battery_charge.to_i
          score += v
          break
        end
      end
    end

    if type == "others"
      score += FRONT_WIPER_SCORE[self.front_wiper_desc]
      score += BACK_WIPER_SCORE[self.back_wiper_desc]
      score += AUTO_TOOLS_SCORE[self.warning_board_desc]
      score += AUTO_TOOLS_SCORE[self.extinguisher_desc]
    end
    score
  end

  def calc_total_score
    score = 0.0
    score += self.calc_score("wheels_brake")
    score += self.calc_score("lights")
    score += self.calc_score("filter_oil_battery")
    score += self.calc_score("others")
  end

  OILTYPE_TO_KM = [5000, 7500, 10000]
  SERVICES_GROUP1 = %w[oil_filter_changed]
  SERVICES_GROUP2 = %w[oil_filter_changed cabin_filter_changed]
  SERVICES_GROUP3 = %w[oil_filter_changed air_filter_changed cabin_filter_changed]
  NEXT_SERVICES_RULE = {5000 => {0 => SERVICES_GROUP1, 1 => SERVICES_GROUP3},
                      7500 => {0 => SERVICES_GROUP2, 1 => SERVICES_GROUP3},
                      10000 => {0 => SERVICES_GROUP2, 1 => SERVICES_GROUP3}}

  def next_maintain_km_by_oil
    km = 0
    self.order.parts.each do |p|
      if p.part_type.name == I18n.t(:engine_oil)
        km = OILTYPE_TO_KM[p.motoroil_type] if p.motoroil_type
      end
    end
    km
  end

  def next_maintain_time
    next_date = ''
    km_period = self.next_maintain_km_by_oil
    if km_period != 0 && self.buy_date && self.curr_km.to_i != 0
      days = km_period * (self.created_at.to_date - self.buy_date) / self.curr_km.to_i
      next_date = self.created_at.to_date + days
    end
    next_date
  end

  def next_maintain_services
    services = []
    km_period = self.next_maintain_km_by_oil
    services = NEXT_SERVICES_RULE[km_period][(self.curr_km.to_i / km_period).to_i % 2] if km_period != 0
    services
  end

  validates :order_id, presence: true

  def as_json(options = nil)
    h = super :except => [:_id, :created_at, :updated_at, :buy_date, :VIN, :insurance_date, :engine_num, :order_id,
      :oil_out, :oil_in, :oil_sample_collected, :oil_filter_changed, :oil_filter_not_changed_reason, :air_filter_changed, :air_filter_not_changed_reason,
      :cabin_filter_changed, :cabin_filter_not_changed_reason]
  end
end
