class CreateLoveFunds < ActiveRecord::Migration[5.0]
  def change
    create_table :love_funds do |t|
      t.string     :participate, index: true
      t.date       :participate_date, index: true
      t.date       :cancel_date, index: true
      t.decimal    :monthly_deduction, precision: 10, scale: 2, index: true
      t.references :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
