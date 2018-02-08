class ChangeColumnsInPunishment < ActiveRecord::Migration[5.0]
  def change
    remove_column :punishments, :punishment_status, :string, default: :punishing, index: true
    remove_column :punishments, :punishment_result_validity_end_date, :datetime

    remove_column :punishments, :incident_time_from, :datetime, null: false
    remove_column :punishments, :incident_time_to, :datetime, null: false
    remove_column :punishments, :incident_place, :string, null: false
    remove_column :punishments, :incident_discoverer, :string, null: false
    remove_column :punishments, :incident_discoverer_phone, :string, null: false
    remove_column :punishments, :incident_handler, :string, null: false
    remove_column :punishments, :incident_handler_phone, :string, null: false
    remove_column :punishments, :incident_description, :string, null: false
    remove_column :punishments, :incident_financial_influence, :boolean, null: false

    add_column :punishments, :punishment_status, :string

    add_column :punishments, :incident_time_from, :datetime
    add_column :punishments, :incident_time_to, :datetime
    add_column :punishments, :incident_place, :string
    add_column :punishments, :incident_discoverer, :string
    add_column :punishments, :incident_discoverer_phone, :string
    add_column :punishments, :incident_handler, :string
    add_column :punishments, :incident_handler_phone, :string
    add_column :punishments, :incident_description, :string
    add_column :punishments, :incident_financial_influence, :boolean

    add_column :punishments, :records_in_where, :string
    add_column :punishments, :profile_validity_period, :integer
    add_column :punishments, :profile_penalty_score, :integer
    add_column :punishments, :profile_abolition_date, :datetime
    add_column :punishments, :profile_punishment_status, :string
    add_column :punishments, :profile_remarks, :string
  end
end
