class RemoveFromToFromWorkExperences < ActiveRecord::Migration[5.0]
  def change
    remove_column :work_experences, :work_experience_from, :date
    remove_column :work_experences, :work_experience_to, :date
  end
end
