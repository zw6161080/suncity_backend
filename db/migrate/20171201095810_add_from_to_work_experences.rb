class AddFromToWorkExperences < ActiveRecord::Migration[5.0]
  def change
    add_column :work_experences, :work_experience_from, :datetime
    add_column :work_experences, :work_experience_to, :datetime
  end
end
