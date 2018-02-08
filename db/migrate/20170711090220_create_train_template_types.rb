class CreateTrainTemplateTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :train_template_types do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name

      t.timestamps
    end
  end
end
