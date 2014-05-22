class Wheel
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String, default: ""
  field :brand, type: String, default: ""
  field :factory_data, type: Date
  field :tread_depth, type: Float, default: 0
  field :tread_aging, type: Integer, default: 0
  field :tread_crack, type: Integer, default: 0
  field :pressure, type: Float, default: 0
  field :width, type: Integer, default: 0
  field :brake_pad, type: Float, default: 0
  field :brake_disc, type: String, default: ""

  embedded_in :maintain, :inverse_of => :wheels

  #validates_format_of :name, in: ["spare", "left_front", "right_front", "left_back", "right_back"]
  validates :name, uniqueness:  {case_sensitive: false}, presence: true

  attr_accessible :name, :brand,
    :factory_data, :tread_depth, :tread_desc, :sidewall_desc,
    :pressure, :width, :brake_pad, :brake_disc

end

class Maintain
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  field :outlook_desc, type: String, default: ""
  field :buy_date, type: DateTime
  field :VIN, type: String
  field :insurance_date, type: DateTime
  field :auto_color, type: String
  field :engine_num, type: String

  #light check
  field :no_lights_check, type: Boolean, default: false
  field :high_beam, type: Integer, default: 0
  field :low_beam, type: Integer, default: 0
  field :turn_light, type: Integer, default: 0
  field :brake_light, type: Integer, default: 0
  field :fog_light, type: Integer, default: 0
  field :small_light, type: Integer, default: 0
  field :backup_light, type: Integer, default: 0
  field :room_light, type: Integer, default: 0
  field :license_light, type: Integer, default: 0

  field :curr_oil, type: Integer, default: 0
  field :oil_out, type: Integer, default: 0
  field :oil_in, type: Integer, default: 0
  field :oil_desc, type: Integer, default: 0
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
  field :antifreeze_desc, type: Integer, default: 0
  field :antifreeze_freezing_point, type: Integer, default: 0
  field :power_steering_oil_desc, type: Integer, default: 0
  field :gearbox_oil_desc, type: Integer, default: 0
  field :glass_water_lock, type: Boolean, default: false
  field :glass_water_added, type: Boolean, default: false
  field :battery_life, type: String, default: ""
  field :battery_charge_desc, type: Integer, default: 0
  field :battery_health_index, type: String, default: ""
  field :battery_outlook_desc, type: Integer, default: 0
  field :battery_light_color, type: String, default: ""
  field :battery_head_desc, type: Integer, default: 0

  field :front_wiper_desc, type: Integer, default: 0
  field :back_wiper_desc, type: Integer, default: 0
  field :extinguisher_existed, type: Boolean, default: false
  field :warning_board_existed, type: Boolean, default: false
  field :spare_tire_existed, type: Boolean, default: false

  field :km_be_zero, type: Boolean, default: false
  field :curr_km, type: String, default: ""
  field :next_maintain_km, type: String, default: ""
  field :next_maintain_time, type: String, default: ""

  belongs_to :order
  PART_DESC = [0, 1, 2, 3, 4]
  PART_DESC_STRINGS = %w[init bad normal good lack]
  TIRE_AGEING_LEVLE = [0, 1, 2]
  TIRE_AGEING_LEVLE_STRINGS = %w[slight general serious]
  TIRE_CRACK_LEVLE = [0, 1]
  TIRE_CRACK_LEVLE_STRINGS = %w[partial block]
  OIL_DESC = [0, 1]
  OIL_DESC_STRINGS = %w[clean dirty]

  embeds_many :wheels, :cascade_callbacks => true
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
    :no_lights_check, :high_beam, :low_beam, :turn_light, :brake_light, :fog_light,
    :small_light, :backup_light, :room_light, :license_light,
    :curr_oil, :oil_out, :oil_in, :oil_desc, :oil_filter_changed, :oil_filter_not_changed_reason,
    :air_filter_desc, :air_filter_changed, :air_filter_not_changed_reason,
    :cabin_filter_desc, :cabin_filter_changed, :cabin_filter_not_changed_reason,
    :brake_oil_desc, :brake_oil_boiling_point, :antifreeze_desc, :antifreeze_freezing_point,
    :power_steering_oil_desc, :gearbox_oil_desc, :glass_water_lock, :glass_water_added, :battery_life,
    :battery_charge_desc, :battery_health_index, :battery_outlook_desc, :battery_light_color, :battery_head_desc,
    :front_wiper_desc, :back_wiper_desc, :extinguisher_existed, :warning_board_existed, :spare_tire_existed,
    :km_be_zero, :curr_km, :next_maintain_km, :next_maintain_time,
    :order_id,
    :wheel_ids, :wheels_attributes

  def as_json(options = nil)
    h = super :except => [:_id]
  end
end
