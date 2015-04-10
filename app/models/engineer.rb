class Engineer < User

  paginates_per 15

  # info
  field :identity_card

  attr_accessible :identity_card
  # info

  field :roles, type: Array, default: ["5"]

  LEVEL_STR = %w-培训 养护技师 高级养护技师 资深养护技师 首席养护技师-
  field :level, type: Integer, default: 0

  # 工牌
  field :work_tag_number, type: String
  validates :work_tag_number, uniqueness: true, length: { is: 7 }, allow_blank: true

  attr_accessible :work_tag_number, :level, :aasm_state, :work_tag_number

  # 入职、离职 时间
  field :boarding_date, type: Date
  field :leaving_date, type: Date

  include AASM
  BOARDING_TEST_LIMIT = 2
  field :aasm_state

  has_many :testings # 考卷

  aasm do
    state :training, :initial => true # 培训
    state :boarding # 上岗
    state :dimissory # 离职

    event :exam do
      transitions from: :training, to: :boarding do
        guard do
          boarding_exam_pass?
        end
        after do
          generate_working_tag_number
          set_boarding_date
          update_level
        end
      end

      transitions from: :training, to: :dimissory do
        guard do
          !boarding_exam_pass? && !can_take_boarding_exam?
        end
        after do
          set_leaving_date
        end
      end
    end
  end

  def update_level
    self.level = 1
    save
  end

  def boarding_exam_pass?
    testings.boarding.any?{ |t| t.pass? }
  end

  def can_take_boarding_exam?
    testings.boarding.length < BOARDING_TEST_LIMIT && !boarding_exam_pass?
  end

  def set_boarding_date
    self.boarding_date = Time.now
    save
  end

  def set_leaving_date
    self.leaving_date = Time.now
    save
  end

  def generate_working_tag_number
    year_mon = Time.now.strftime("%y%m")

    if last_engineer = Engineer.where(work_tag_number: /^#{year_mon}.*/).desc(:work_tag_number).first
      self.work_tag_number = "#{last_engineer.work_tag_number.to_i + 1}"
    else
      self.work_tag_number = "#{year_mon}001"
    end

    save
  end

  ####

  class << self
    # migrate所有角色为技师的User的type为Engineer, 用完可以删除

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

  def level_str
    LEVEL_STR[level]
  end

end
