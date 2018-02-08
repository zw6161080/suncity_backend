module ProfileAble
  module ClassMethods

    # 创建并获取所有section的fields/schema的配置
    def template(region:)
      ProfileSectionCollection.new(
        self.section_config(region: region)
      )
    end

    def create_template(region:)
      ProfileSectionCollection.new(
        self.create_section_config(region: region)
      )
    end



    # 获取所有section的fields/schema配置的同时，写入对应的value, 并返回ProfileSectionCollection对象
    def fork_template(region:, params:)
      template = self.template(region: region)
      template.merge_params(params)
      template
    end

    def section_config_class
      ProfileSection
    end

    # 获取所有的section的配置
    def section_config(region:)
      self.section_config_class.all(region: region).select do |section|
        section.belongs_to_region?(region)
      end
    end

    # 获取所有的create_section的配置
    def create_section_config(region:)
      self.section_config_class.create_all(region: region).select do |section|
        section.belongs_to_region?(region)
      end
    end

    def pseudo_fields
      {}
    end

    # 获取所有section的fields/schema配置的同时，写入对应的value, 并更新profile存储
    def fork_template!(region:, params:, attributes:{})
      sections = self.fork_template(region: region, params: params)
      profile = self.new
      profile.sections = sections
      profile.attributes = attributes
      profile.save!
      profile
    end

    # 返回Profile里对应key的所有Fields
    def find_fields(keys)
      keys.map do |key|
        self.find_field(key)
      end
    end

    # 返回Profile里对应key的Field
    def find_field(key)
      if pseudo_fields.key?(key)
        pseudo_fields[key]
      else
        Field.find(key)
      end
    end
  end

  module InstanceMethods
    def fill_sections
      unless self.new_record?
        self.sections = self.class.fork_template(region: self.region, params: self.data)
      end
    end

    def sections=(sections)

      @sections = sections
      sections.supervisor = self
    end

    def sections
      @sections
    end

    # dispatch edit action to section collection
    def edit_field(params)
      self.sections.send('edit_field', params)
    end

    def add_row(params)
      self.sections.send('add_row', params)
    end

    def edit_row_fields(params)
      self.sections.send('edit_row_fields', params)
    end

    def remove_row(params)
      self.sections.send('remove_row', params)
    end

    def publish(event_name, params)
      self.user.call(event_name, params)
    end

    def as_json_only_fields(fields)
      result = {}

      fields.each do |field_key|
        if self.attributes.keys.include?(field_key)
          result[field_key] = self.try(field_key)
        elsif self.class.pseudo_fields.keys.include?(field_key)
          result[field_key] = self.pseudo_value(field_key)
        else
          field_sections.each do |section|
            if section.field_keys.include?(field_key)
              field = section.find_field(field_key)
              if ProfileService.respond_to?(field.key) && (self.is_a? Profile)
                value =  ProfileService.send(field.key, self.user)
                if (value.is_a? Hash )|| (value.is_a? ActiveRecord::Base )
                  value = value.as_json.with_indifferent_access.send(:[],self.class.select_language)
                elsif (value.is_a? Time) || (value.is_a? Date)
                  value = value.strftime("%Y/%m/%d")
                else
                  value
                end
                result[field_key] = value
              else
                result[field_key] = field.render_value(self.class.select_language)
              end
            end
          end

        end
      end

      result
    end

    def field_sections
      sections.select do |section|
        section.respond_to?('fields')
      end
    end

    def reload(*args)
      super
      #!important must fill section after reload
      # other wise sections will not the lasted
      self.fill_sections
    end

    def on_save
      self.data = sections.to_values
      self.region = sections.region
      sections.on_save
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
