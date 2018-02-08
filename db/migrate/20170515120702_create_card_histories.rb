class CreateCardHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :card_histories do |t|
      t.date :date_to_get_card
      t.date :new_approval_valid_date
      t.date :card_valid_date
      t.date :certificate_valid_date
      t.string :new_or_renew
      t.references :card_profile, foreign_key: true

      t.timestamps
    end
  end
end
