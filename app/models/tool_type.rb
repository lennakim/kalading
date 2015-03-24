class ToolType
  include Mongoid::Document
  include Mongoid::Timestamps

  # 随人工具 随车工具
  CATEGORIES = %w[with_engineer with_vehicle]

  field :name, type: String
  field :category, type: String
  field :unit, type: String

  validates :name, presence: true
  validates :category, inclusion: { in: CATEGORIES }

  class << self
    def categories_collection
      CATEGORIES.map do |category|
        [category_humanize(category), category]
      end
    end

    def category_humanize(category)
      I18n.t("mongoid.attributes.tool_type.categories.#{category}")
    end
  end

  def category_humanize
    self.class.category_humanize(category)
  end
end
