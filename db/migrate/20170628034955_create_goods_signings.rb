class CreateGoodsSignings < ActiveRecord::Migration[5.0]
  def change
    create_table :goods_signings do |t|
      t.datetime   :distribution_date
      t.string     :goods_status
      t.references :user, foreign_key: true, index: true
      t.references :goods_category, foreign_key: true, index: true
      t.integer    :distribution_count
      t.decimal    :distribution_total_value, precision: 15, scale: 2
      t.datetime   :sign_date
      t.datetime   :return_date
      t.references :distributor, foreign_key: {to_table: :users}, index: true
      t.string     :remarks

      t.timestamps
    end
  end
end
