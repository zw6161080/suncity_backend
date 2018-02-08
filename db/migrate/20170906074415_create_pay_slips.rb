class CreatePaySlips < ActiveRecord::Migration[5.0]
  def change
    create_table :pay_slips do |t|
      t.datetime :year_month
      t.datetime :salary_begin
      t.datetime :salary_end
      t.integer :user_id
      t.boolean :entry_on_this_month
      t.boolean :leave_on_this_month
      t.timestamps
    end
  end
end
