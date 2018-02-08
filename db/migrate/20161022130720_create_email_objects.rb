class CreateEmailObjects < ActiveRecord::Migration[5.0]
  def change
    create_table :email_objects do |t|
      t.jsonb :to
      t.string :subject
      t.text :body
      t.string :the_object
      t.integer :the_object_id

      t.timestamps
    end
  end
end
