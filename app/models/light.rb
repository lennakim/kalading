# 保养记录的灯光信息
class Light
  include Mongoid::Document

  field :name, type: String, default: ""
  field :desc, type: Array, default: [0]

  embedded_in :maintain, :inverse_of => :lights
  DESC = [0,1,4,5,6,7,8,9]
  DESC_STRINGS = %w[bright undetectable not_bright right_not_bright left_front_not_bright right_front_not_bright left_back_not_bright right_back_not_bright high_not_bright back_fog_not_bright]
  NAME_STRINGS = %w[high_beam low_beam turn_light fog_light small_light backup_light brake_light]
  validates :name, uniqueness: {case_sensitive: false}, presence: true

  attr_accessible :name, :desc

  SCORE = {'high_beam' => {0=>2,2=>-2,4=>-1,5=>-1}, 'low_beam' => {0=>2,2=>-2,4=>-1,5=>-1}, 'turn_light' => {0=>4,2=>-4,4=>-1,5=>-1,6=>-1,7=>-1},
    'fog_light' => {0=>1,2=>-1,6=>-0.5,7=>-0.5,9=>-0.5}, 'small_light' => {0=>2,2=>-2,4=>-0.5,5=>-0.5,6=>-0.5,7=>-0.5},
    'backup_light' => {0=>1,2=>-1,6=>-0.5,7=>-0.5,1=>1}, 'brake_light' => {0=>3,2=>-3,6=>-1.5,7=>-1.5,8=>-1,1=>3},
  }
  def score
    score = SCORE[self.name][0]
    self.desc.each do |d|
      score += SCORE[self.name][d] if SCORE.include?(self.name) && SCORE[self.name].include?(d) && SCORE[self.name][d] < 0
    end
    score
  end
end
