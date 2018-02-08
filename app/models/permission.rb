# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  resource   :string
#  action     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  region     :string
#
# Indexes
#
#  index_permissions_on_region  (region)
#

class Permission < ApplicationRecord

  validates_uniqueness_of :action, scope: [:resource, :region]

  def self.global_permissions_config
    Config.get(:global_permissions).fetch('global_permissions', {})
  end

  def self.global(action)
    Permission.where(resource: 'global').find_by_action(action.to_s)
  end

  def self.policies
    resources_actions = []
    ApplicationPolicy.policies.each do |policy|
      policy.actions.each do |action|
        resources_actions.push({ resource: policy.resource , action: action, chinese_name: policy.try(:chinese_name)[action], english_name: policy.try(:english_name)[action] })
      end
    end
    # resources_actions.push({ 'global' => self.global_permissions_config.first.last.keys })
    self.global_permissions_config.first.last.keys.each do |action|
      resources_actions.push({ resource: 'global' , action: action, chinese_name: self.global_permissions_config['chinese_name'][action], english_name: self.global_permissions_config['english_name'][action] })
    end
    Config.get('permission_selects')["permissions"].each do |permission|
      resources_actions.push({ resource: permission['resource'], action: permission['action'], chinese_name: permission['chinese_name'], english_name: permission['english_name'], simple_chinese_name: permission['simple_chinese_name'] })
    end
    resources_actions
  end

  def self.policies_translations
    resources_actions = []
    ApplicationPolicy.policies.each do |policy|
      policy.actions.each do |action|
        resources_actions.push({ resource: policy.resource , action: action, chinese_name: policy.try(:chinese_name)[action], english_name: policy.try(:english_name)[action] })
      end
    end
    self.global_permissions_config.first.last.keys.each do |action|
      resources_actions.push({ resource: 'global' , action: action, chinese_name: self.global_permissions_config['chinese_name'][action], english_name: self.global_permissions_config['english_name'][action] })
    end
    Config.get('permission_selects')["permissions"].each do |permission|
      resources_actions.push({ resource: permission['resource'], action: permission['action'], chinese_name: permission['chinese_name'], english_name: permission['english_name'], simple_chinese_name: permission['simple_chinese_name'] })
    end
    resources_actions
  end

end
