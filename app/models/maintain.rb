class Wheel
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String, default: ""
  field :brand, type: String, default: ""
  field :factory_data_checked, type: Boolean, default: true
  field :factory_data, type: String, default: ""
  field :tread_depth, type: Float, default: 0
  field :ageing_desc, type: Integer, default: 0
  field :tread_desc, type: Array, default: [0]
  field :sidewall_desc, type: Array, default: [0]
  field :pressure, type: Float, default: 0
  field :width, type: Integer, default: 0
  field :brake_pad_checked, type: Boolean, default: true
  field :brake_pad_thickness, type: Float, default: 0
  field :brake_disc_desc, type: Array, default: [0]

  embedded_in :maintain, :inverse_of => :wheels

  NAME_STRINGS = %w[spare left_front right_front left_back right_back]
  AGEING_STRINGS = %w[slight general serious]
  TREAD_STRINGS = %w[normal local_cracking wear_in_middle wear_in_sides puncture]
  SIDEWALL_STRINGS = %w[normal local_cracking cut wear_in_sides swelling abnormal_wear]
  BRAKE_DISC_STRINGS = %w[no_uneven_wear uneven_wear recommend_replace not_recommend_replace undetectable]
  AGEING_SCORE = [1,0.5,0]
  TREAD_SCORE = [1,-0.25,-0.25,-0.25,-0.25]
  SIDEWALL_SCORE = [1.5,-0.25,-0.25,-0.25,-0.5,-0.25]
  BRAKE_DISC_SCORE = [1,0,0,1,1]
  LIFE_SCORE = {0..365*3 => 1, 365*3..365*5 => 0.5}
  PRESSURE_SCORE = {1..2 => 1, 2..2.5 => 2, 2.5..5 => 1}
  TREAD_DEPTH_SCORE = {1.5..3 => 0.5, 3..5 => 1, 5..100 => 1.5}
  BRAKE_PAD_THICKNESS_SCORE = {2..4 => 1, 4..100 => 2}
  validates :name, uniqueness:  {case_sensitive: false}, presence: true

  attr_accessible :name, :brand, :factory_data, :factory_data_checked,
    :tread_depth, :ageing_desc, :tread_desc, :sidewall_desc,
    :pressure, :width, :brake_pad_checked, :brake_pad_thickness, :brake_disc_desc
    
  def score
    score = 0.0
    days = (Date.today() - (Date.new(2000 + self.factory_data[2,2].to_i) + self.factory_data[0,2].to_i.weeks)).to_i
    LIFE_SCORE.each do |k, v|
      if k.include?(days)
        score += v
        break
      end
    end

    PRESSURE_SCORE.each do |k, v|
      if k.include? self.pressure
        score += v
        break
      end
    end
    if self.name != "spare"
      TREAD_DEPTH_SCORE.each do |k, v|
        if k.include? self.tread_depth
          score += v
          break
        end
      end
      score += AGEING_SCORE[self.ageing_desc]
      score += TREAD_SCORE[0]
      self.tread_desc.each do |v|
        score += TREAD_SCORE[v] if TREAD_SCORE[v] < 0
      end
      score += SIDEWALL_SCORE[0]
      self.sidewall_desc.each do |v|
        score += SIDEWALL_SCORE[v] if SIDEWALL_SCORE[v] < 0
      end
      if !self.brake_pad_checked 
        score += 2
      else
        BRAKE_PAD_THICKNESS_SCORE.each do |k, v|
          if k.include? self.brake_pad_thickness
            score += v
            break
          end
        end
      end
      
      self.brake_disc_desc.each do |v|
        score += BRAKE_DISC_SCORE[v]
      end
    end
    score
  end
end

class Light
  include Mongoid::Document
  
  field :name, type: String, default: ""
  field :desc, type: Array, default: [0]
  
  embedded_in :maintain, :inverse_of => :lights
  DESC = [0,1,4,5,6,7,8,9]
  DESC_STRINGS = %w[bright undetectable left_not_bright right_not_bright left_front_not_bright right_front_not_bright left_back_not_bright right_back_not_bright high_not_bright back_fog_not_bright]
  NAME_STRINGS = %w[high_beam low_beam turn_light fog_light small_light backup_light brake_light]
  validates :name, uniqueness: {case_sensitive: false}, presence: true
  
  attr_accessible :name, :desc

  SCORE = {'high_beam' => {0=>2,4=>-1,5=>-1}, 'low_beam' => {0=>2,4=>-1,5=>-1}, 'turn_light' => {0=>4,4=>-1,5=>-1,6=>-1,7=>-1},
    'fog_light' => {0=>1,6=>-0.5,7=>-0.5,9=>-0.5}, 'small_light' => {0=>2,4=>-0.5,5=>-0.5,6=>-0.5,7=>-0.5},
    'backup_light' => {0=>1,6=>-0.5,7=>-0.5,1=>1}, 'brake_light' => {0=>3,6=>-1.5,7=>-1.5,8=>-1,1=>3},
  }
  def score
    score = SCORE[self.name][0]
    self.desc.each do |d|
      score += SCORE[self.name][d] if SCORE[self.name].include?(d) && SCORE[self.name][d] < 0 
    end
    score
  end

end

class Maintain
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  field :outlook_desc, type: String, default: ""
  field :buy_date, type: Date
  field :VIN, type: String, default: ""
  field :insurance_date, type: String, default: ""
  field :auto_color, type: String, default: ""
  field :engine_num, type: String, default: ""

  field :oil_position, type: Integer, default: 0
  field :oil_out, type: Integer, default: 0
  field :oil_in, type: Integer, default: 0
  field :oil_desc, type: Integer, default: 0
  field :oil_sample_collected, type: Boolean, default: false
  field :oil_sample_number, type: Integer, default: 0
  field :oil_filter_changed, type: Boolean, default: false
  field :oil_filter_not_changed_reason, type: String, default: ""

  field :air_filter_desc, type: Integer, default: 0
  field :air_filter_changed, type: Boolean, default: false
  field :air_filter_not_changed_reason, type: String, default: ""

  field :cabin_filter_desc, type: Integer, default: 0
  field :cabin_filter_changed, type: Boolean, default: false
  field :cabin_filter_not_changed_reason, type: String, default: ""

  field :brake_oil_desc, type: Integer , default: 0
  field :brake_oil_boiling_point, type: Integer, default: 0
  field :brake_oil_position, type: Integer , default: 0
  field :antifreeze_desc, type: Integer, default: 0
  field :antifreeze_freezing_point, type: Integer, default: 0
  field :antifreeze_position, type: Integer, default: 0
  field :antifreeze_color, type: String, default: ""
  field :steering_oil_desc, type: Integer, default: 0
  field :steering_oil_position, type: Integer, default: 0
  field :gearbox_oil_desc, type: Integer, default: 0
  field :gearbox_oil_position, type: Integer, default: 0
  field :glass_water_desc, type: Integer, default: 0
  field :glass_water_add, type: Boolean, default: false
  field :glass_water_amount, type: Integer, default: 0
  field :battery_desc, type: Integer, default: 0
  field :battery_charge, type: String, default: ""
  field :battery_health, type: String, default: ""
  field :battery_light_color, type: String, default: ""
  field :battery_head_desc, type: Integer, default: 0
  field :engine_hose_and_line_desc, type: Integer, default: 0

  field :front_wiper_desc, type: Integer, default: 0
  field :back_wiper_desc, type: Integer, default: 0
  field :extinguisher_desc, type: Integer, default: 0
  field :warning_board_desc, type: Integer, default: 0
  field :spare_tire_desc, type: Integer, default: 0

  field :km_be_zero, type: Boolean, default: false
  field :last_km, type: String, default: ""
  field :curr_km, type: String, default: ""
  field :next_maintain_km, type: String, default: ""
  field :comment, type: String, default: ""
  field :total_time, type: Integer, default: 0

  belongs_to :order
  
  POSITION_STRINGS = %w[high middle low undetectable]
  OIL_STRINGS = %w[muddy dirty serious_dirty]
  OIL_POSITION_STRINGS = %w[middle high low]
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
  OIL_SCORE = [2,1,0] 
  ANTIFREEZE_SCORE = [2,1,0]
  OTHER_OIL_SCORE = [1,0.5,0,1]

  BRAKE_OIL_SCORE = [2,1,0]
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

  def as_json(options = nil)
    h = super :except => [:_id, :created_at, :updated_at, :buy_date, :VIN, :insurance_date, :engine_num, :order_id,
      :oil_out, :oil_in, :oil_sample_collected, :oil_filter_changed, :oil_filter_not_changed_reason, :air_filter_changed, :air_filter_not_changed_reason,
      :cabin_filter_changed, :cabin_filter_not_changed_reason]
  end
end
