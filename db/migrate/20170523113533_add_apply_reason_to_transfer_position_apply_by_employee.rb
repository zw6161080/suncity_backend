class AddApplyReasonToTransferPositionApplyByEmployee < ActiveRecord::Migration[5.0]
  def change
    add_column :transfer_position_apply_by_employees, :apply_reason, :text
    add_column :transfer_position_apply_by_employees, :interview_result_by_department, :boolean
    add_column :transfer_position_apply_by_employees, :interview_comment_by_department, :text
    add_column :transfer_position_apply_by_employees, :interview_result_by_header, :boolean
    add_column :transfer_position_apply_by_employees, :interview_comment_by_header, :text
  end
end
