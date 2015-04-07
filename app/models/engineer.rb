class Engineer < User

  paginates_per 15

  field :roles, type: Array, default: ["5"]

  LEVEL_STR = %w-养护技师 高级养护技师 资深养护技师 首席养护技师-
  field :level, type: Integer, default: 0

  # 工牌 TODO 7位
  field :work_tag_number, type: String
  # TODO：目前技师的工牌都是空，导致update_realtime_info 抛出validation error

  # validates :work_tag_number, uniqueness: true, length: { is: 7 }

  # 所配车辆 TODO

  attr_accessible :work_tag_number

  # 技师状态 培训状态 -- 养护技师状态(生成工号)

  include AASM
  field :boarding_exam_times, type: Integer, default: 0
  field :aasm_state

  has_many :testings
  has_many :examination_papers, class_name: "Testing", inverse_of: :examiner

  aasm do
    state :training, :initial => true # 培训技师
    state :boarding # 上岗

    event :exam do
      transitions from: :training, to: :boarding do
        guard do
          exam_pass?
        end
      end

      after do
        generate_working_tag_number
      end
    end
  end

  def exam_pass?
    true
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
    def migrate_user_to_engineer
      User.where(roles: "5").update_all _type: 'Engineer'
    end

    def migrate_all_engineers_status_0
      Engineer.update_all status: 0
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

  def level_str
    LEVEL_STR[level]
  end

end
