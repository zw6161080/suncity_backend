class CreateLentTemporarilyItems < ActiveRecord::Migration[5.0]
  def change
    create_table :lent_temporarily_items do |t|

      t.string :region
      t.integer :user_id
      t.integer :lent_temporarily_apply_id
      t.date :lent_date
      t.date :return_date
      t.integer :lent_location_id
      t.integer :lent_salary_template_id
      t.integer :return_salary_template_id
      t.text :comment

      t.timestamps
    end
  end
end
