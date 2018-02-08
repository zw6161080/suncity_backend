# coding: utf-8
# == Schema Information
#
# Table name: roles
#
#  id                               :integer          not null, primary key
#  chinese_name                     :string
#  english_name                     :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  key                              :string
#  fixed                            :boolean
#  simple_chinese_name              :string
#  introduction_chinese_name        :string
#  introduction_english_name        :string
#  introduction_simple_chinese_name :string
#

class Role < ApplicationRecord
  has_and_belongs_to_many :users
  has_and_belongs_to_many :permissions

  def self.load_predefined
    self.add_fixed_group
    admin_role = self.find_by(key: 'admin_group')

    admin_role.add_permission_by_attribute('admin', 'global', 'macau')
    admin_role.add_permission_by_attribute('access_company_structure_management', 'global', 'macau')
    admin_role.add_permission_by_attribute('index', 'Role', 'macau')
    admin_role.add_permission_by_attribute('update', 'Role', 'macau')

    admin_role
  end

  # validates :name, presence: true, uniqueness: true
  def has_permission?(permission)
    permissions.exists?(permission.id)
  end

  def add_permission(permission)
    permissions << permission unless has_permission?(permission)
  end

  def remove_permission(permission)
    permissions.delete(permission) if has_permission?(permission)
  end

  def find_permission_by_attribute(action, resource, region)
    Permission.find_or_create_by({
      action: action,
      resource: resource,
      region: region
    })
  end

  def add_permission_by_attribute(action, resource, region)
    permission = find_permission_by_attribute(action, resource, region)
    add_permission(permission)
  end

  def remove_permission_by_attribute(action, resource, region)
    permission = find_permission_by_attribute(action, resource, region)
    remove_permission(permission)
  end

  def has_user?(user)
    users.exists?(user.id)
  end

  def add_user(user)
    users << user unless has_user?(user)
  end

  def remove_user(user)
    users.delete(user) if has_user?(user)
  end

  def add_user_by_id(user_id)
    user = User.find_by_id(user_id)
    add_user(user)
  end

  def remove_user_by_id(user_id)
    user = User.find_by_id(user_id)
    remove_user(user)
  end

  def self.attend_and_payment_group_user_ids
    attendance_group_users = Role.find_by(key: 'attendance_group')&.users
    attendance_group_user_ids = attendance_group_users.empty? ? [] : attendance_group_users.pluck(:id).uniq
    payment_group_users = Role.find_by(key: 'payment_group')&.users
    payment_group_user_ids = payment_group_users.empty? ? [] : payment_group_users.pluck(:id).uniq
    (attendance_group_user_ids + payment_group_user_ids).uniq
  end

  def self.payment_group_user_ids
    payment_group_users = Role.find_by(key: 'payment_group')&.users
    payment_group_user_ids = payment_group_users.empty? ? [] : payment_group_users.pluck(:id).uniq
    payment_group_user_ids
  end

  private

  def self.add_fixed_group
    fixed_group_config = Config.get('role_fixed_group')
    fixed_group_config.each do |key, value|
      Role.find_or_create_by(key:key).update(value)
    end
  end

end
