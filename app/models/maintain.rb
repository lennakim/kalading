class Wheel
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String, default: ""
  field :brand, type: String, default: ""
  field :factory_data, type: Date
  field :tread_depth, type: Float, default: 0
  field :ageing_desc, type: Integer, default: 0
  field :tread_desc, type: Array, default: [0]
  field :sidewall_desc, type: Array, default: [0]
  field :pressure, type: Float, default: 0
  field :width, type: Integer, default: 0
  field :brake_pad_checked, type: Boolean, default: true
  field :brake_pad_thickness, type: Float, default: 0
  field :brake_disc_desc, type: Integer, default: 0

  embedded_in :maintain, :inverse_of => :wheels

  NAME_STRINGS = %w[spare left_front right_front left_back right_back]
  AGEING_STRINGS = %w[slight general serious]
  TREAD_STRINGS = %w[normal local_cracking wear_in_middle wear_in_sides puncture]
  SIDEWALL_STRINGS = %w[normal local_cracking cut worn_in_sides swelling abnormal_wear]
  BRAKE_DISC_STRINGS = %w[no_uneven_wear uneven_wear recommend_replace not_recommend_replace undetectable]
  
  validates :name, uniqueness:  {case_sensitive: false}, presence: true

  attr_accessible :name, :brand, :factory_data,
    :tread_depth, :ageing_desc, :tread_desc, :sidewall_desc,
    :pressure, :width, :brake_pad_checked, :brake_pad_thickness, :brake_disc_desc

end

class Light
  include Mongoid::Document
  
  field :name, type: String, default: ""
  field :desc, type: Array, default: [0]
  
  embedded_in :maintain, :inverse_of => :lights
  
  DESC_STRINGS = %w[bright undetectable left_not_bright right_not_bright left_front_not_bright right_front_not_bright left_back_not_bright right_back_not_bright high_not_bright back_fog_not_bright]

  validates :name, uniqueness: {case_sensitive: false}, presence: true
  
  attr_accessible :name, :desc

end

class Maintain
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  field :outlook_desc, type: String, default: ""
  field :buy_date, type: DateTime
  field :VIN, type: String, default: ""
  field :insurance_date, type: DateTime
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

  field :front_wiper_desc, type: Integer, default: 0
  field :back_wiper_desc, type: Integer, default: 0
  field :extinguisher_desc, type: Integer, default: 0
  field :warning_board_desc, type: Integer, default: 0
  field :spare_tire_desc, type: Integer, default: 0

  field :km_be_zero, type: Boolean, default: false
  field :curr_km, type: String, default: ""
  field :next_maintain_km, type: String, default: ""
  field :comment, type: String, default: ""
  field :total_time, type: Integer, default: 0

  belongs_to :order
  PART_DESC = [0, 1, 2, 3, 4]
  PART_DESC_STRINGS = %w[init bad normal good lack]
  TIRE_AGEING_LEVLE = [0, 1, 2]
  TIRE_AGEING_LEVLE_STRINGS = %w[slight general serious]
  TIRE_CRACK_LEVLE = [0, 1]
  TIRE_CRACK_LEVLE_STRINGS = %w[partial block]
  OIL_DESC = [0, 1]
  OIL_DESC_STRINGS = %w[clean dirty]
  POSITION_STRINGS = %w[high middle low undetectable]
  OIL_STRINGS = %w[muddy dirty serious_dirty]
  OTHER_OIL_STRINGS = %w[clean muddy dirty undetectable]
  FILTER_STRINGS = %w[clean dirty serious_dirty]
  GLASS_WATER_STRINGS = %w[full lack]
  BATTERY_STRINGS = %w[good worn leak undetectable]
  BATTERY_HEAD_STRINGS = %w[good corroded undetectable]
  WIPER_STRINGS = %w[normal recommend_replace none]
  AUTO_TOOLS_STRINGS = %w[existed not_existed undetected]

  embeds_many :wheels, :cascade_callbacks => true
  embeds_many :lights, :cascade_callbacks => true
  embeds_one :outlook_pic, class_name: "Picture"
  embeds_one :auto_front_pic, class_name: "Picture"
  embeds_one :auto_back_pic, class_name: "Picture"
  embeds_one :auto_left_pic, class_name: "Picture"
  embeds_one :auto_right_pic, class_name: "Picture"
  embeds_one :auto_top_pic, class_name: "Picture"
  embeds_one :old_oil_pic, class_name: "Picture"
  embeds_one :oil_filter_pic, class_name: "Picture"
  embeds_one :old_air_filter_pic, class_name: "Picture"
  embeds_one :old_cabin_filter_pic, class_name: "Picture"
  embeds_one :tire_left_front_pic, class_name: "Picture"
  embeds_one :tire_left_back_pic, class_name: "Picture"
  embeds_one :tire_right_front_pic, class_name: "Picture"
  embeds_one :tire_right_back_pic, class_name: "Picture"
  embeds_one :tire_spare_pic, class_name: "Picture"

  accepts_nested_attributes_for :wheels, :allow_destroy => true
  accepts_nested_attributes_for :lights, :allow_destroy => true
  accepts_nested_attributes_for :outlook_pic
  accepts_nested_attributes_for :auto_front_pic
  accepts_nested_attributes_for :auto_back_pic
  accepts_nested_attributes_for :auto_left_pic
  accepts_nested_attributes_for :auto_right_pic
  accepts_nested_attributes_for :auto_top_pic
  accepts_nested_attributes_for :old_oil_pic
  accepts_nested_attributes_for :oil_filter_pic
  accepts_nested_attributes_for :old_air_filter_pic
  accepts_nested_attributes_for :old_cabin_filter_pic
  accepts_nested_attributes_for :tire_left_front_pic
  accepts_nested_attributes_for :tire_left_back_pic
  accepts_nested_attributes_for :tire_right_front_pic
  accepts_nested_attributes_for :tire_right_back_pic
  accepts_nested_attributes_for :tire_spare_pic

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
    :km_be_zero, :curr_km, :next_maintain_km, :comment, :total_time,
    :wheel_ids, :wheels_attributes, :light_ids, :lights_attributes,:order_id

  def as_json(options = nil)
    h = super :except => [:_id, :created_at, :updated_at, :buy_date, :VIN, :insurance_date, :engine_num, :order_id,
      :oil_out, :oil_in, :oil_sample_collected, :oil_filter_changed, :oil_filter_not_changed_reason, :air_filter_changed, :air_filter_not_changed_reason,
      :cabin_filter_changed, :cabin_filter_not_changed_reason]
  end
end
