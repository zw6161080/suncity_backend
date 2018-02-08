class CreateDimissionAppointments < ActiveRecord::Migration[5.0]
  def change
    create_table :dimission_appointments do |t|

      t.string :region

      t.integer :user_id
      t.integer :status
      t.integer :questionnaire_template_id
      t.integer :questionnaire_id

      t.date :last_working_date
      t.string :duration
      t.boolean :had_transfer
      t.date :last_transfer_date

      t.date :appointment_date
      t.datetime :appointment_time
      t.string :appointment_location
      t.text :appointment_description

      t.text :opinion
      t.text :other_opinion
      t.text :summary

      t.integer :inputter_id
      t.date :input_date
      t.string :comment

      t.timestamps
    end
  end
end
