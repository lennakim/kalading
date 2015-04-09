# 保养记录的轮胎信息
class Wheel
  include Mongoid::Document

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

  NAME_STRINGS_WIHT_SPARE = {0=>"left_front", 1=>"right_front", 2=>"left_back", 3=>"right_back", 4=>"spare"}
  NAME_STRINGS = {0=>"left_front", 1=>"right_front", 2=>"left_back", 3=>"right_back"}
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
      score += AGEING_SCORE[self.ageing_desc] if AGEING_SCORE.include?(self.ageing_desc)
      score += TREAD_SCORE[0]
      self.tread_desc.each do |v|
        score += TREAD_SCORE[v] if TREAD_SCORE.include?(v) && TREAD_SCORE[v] < 0
      end
      score += SIDEWALL_SCORE[0]
      self.sidewall_desc.each do |v|
        score += SIDEWALL_SCORE[v] if SIDEWALL_SCORE.include?(v) && SIDEWALL_SCORE[v] < 0
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
        score += BRAKE_DISC_SCORE[v] if BRAKE_DISC_SCORE.include?(v)
      end
    end
    score
  end
end
