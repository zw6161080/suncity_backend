# == Schema Information
#
# Table name: train_template_types
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  simple_chinese_name :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class TrainTemplateType < ApplicationRecord
  def self.update_params
    self.create_params + %w(id)
  end
  def self.batch_update_with_params(create,update,delete)
    result = nil
    ActiveRecord::Base.transaction do
      create.each do|item|
        self.create(item)
      end if create
      update.each do |item|
        self.find(item[:id]).update(item.reject{|k,v| k == :id})
      end if update
      delete.each do |item|
        unless TrainTemplate.pluck(:train_template_type_id).include?(item) || Train.pluck(:train_template_type_id).include?(item)
          self.find(item).destroy
        end
      end if delete
      result = true
    end
    result
  end
end
