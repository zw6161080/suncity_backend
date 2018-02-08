class AddCareerHistoryFieldsToDimission < ActiveRecord::Migration[5.0]
  def change
    add_column :dimissions, :career_history_dimission_reason, :string, null: false, default: ''
    add_column :dimissions, :career_history_dimission_comment, :text
  end
end
