class CreateMessageInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :message_infos do |t|
      t.string :content
      t.string :target_type
      t.string :namespace
      t.integer :targets, :array => true
      t.string :sender_id

	  t.timestamps          
    end
  end
end
