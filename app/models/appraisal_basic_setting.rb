# == Schema Information
#
# Table name: appraisal_basic_settings
#
#  id                             :integer          not null, primary key
#  ratio_superior                 :integer
#  ratio_subordinate              :integer
#  ratio_collegue                 :integer
#  ratio_self                     :integer
#  ratio_others_superior          :integer
#  ratio_others_subordinate       :integer
#  ratio_others_collegue          :integer
#  questionnaire_submit_once_only :boolean
#  introduction                   :string
#  group_A                        :jsonb
#  group_B                        :jsonb
#  group_C                        :jsonb
#  group_D                        :jsonb
#  group_E                        :jsonb
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#

class AppraisalBasicSetting < ApplicationRecord

  has_many :appraisal_attachments, :as => :appraisal_attachable, dependent: :destroy

  def self.effective_groups
    effective_groups = []
    %w[A B C D E].each do |group|
      effective_groups.push(group) if AppraisalBasicSetting.first["group_#{group}"].size > 0
    end
    effective_groups
  end



  def self.load_predefined
    self.first_or_create(Config.get('appraisal_basic_setting')['default'])
  end

end
