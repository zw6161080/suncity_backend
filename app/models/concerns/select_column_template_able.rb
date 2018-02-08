module SelectColumnTemplateAble
  extend ActiveSupport::Concern

  included do
    after_create :select_one_as_default
    after_destroy :select_one_as_default
    before_update :set_other_to_default_false

    scope :region_template_count, ->(region) {
      where(region: region).count
    }

    scope :default_template_count, ->(region){
      where(region: region, default: true).count
    }
  end

  def select_one_as_default
    if default_template_count == 0 and  region_remplate_count > 0
      template = self.class.where(region: region).last
      template.update_column(:default, true)
    end
  end

  def set_other_to_default_false
    if self.default
      self.class.where(region: region)
                .where.not(id: self.id).update_all(default: false)
    end
  end

  def default_template_count
    self.class.default_template_count(self.region)
  end

  def region_remplate_count
    self.class.region_template_count(self.region)
  end

  def select_columns
    self.select_column_keys.map do |key|
      Field.find(key).as_json
    end
  end

  class_methods do
    # get all selectable columns
    def all_selectable_columns(region:)
      self.section_template(region: region).inject([]) do |carry, section|
        next carry if [:salary_information, :holiday_information].include?(section.key.to_sym)
        carry.concat(section.selectable_fields) if section.respond_to?('selectable_fields')
        carry
      end
    end

    def all_selectable_columns_with_section(region:)
      self.section_template(region: region).inject([]) do |carry, section|
        next carry if [:salary_information, :holiday_information].include?(section.key.to_sym)
        if section.respond_to? :selectable_fields
          carry.push({
            chinese_name: section.chinese_name,
            english_name: section.english_name,
            simple_chinese_name: section.simple_chinese_name,
            key: section.key,
            fields: section.selectable_fields
          })
        end
        carry
      end
    end

    #return columns when has default template else default select columns
    def default_columns(region:)
      if default_template_count(region) > 0
        self.where(region: region, default: true).first.select_column_keys
      else
        self.default_select_columns()
      end
    end

    def default_select_columns
      %w(empoid chinese_name english_name)
    end

    def section_template(region:)
      Profile.template(region: region)
    end

    def generate_default_template(templates, region)
      unless default_template_count(region) > 0
        templates.first.update(default: true)  rescue nil
      end
    end
  end

end
