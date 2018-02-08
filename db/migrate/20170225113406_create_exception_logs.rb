class CreateExceptionLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :exception_logs do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
