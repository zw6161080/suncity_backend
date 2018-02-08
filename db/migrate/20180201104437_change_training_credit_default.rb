class ChangeTrainingCreditDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default :trains, :training_credits, from: nil, to: 0
  end
end
