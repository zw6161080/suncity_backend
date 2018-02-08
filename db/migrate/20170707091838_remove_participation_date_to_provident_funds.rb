class RemoveParticipationDateToProvidentFunds < ActiveRecord::Migration[5.0]
  def change
    remove_column :provident_funds, :participation_date, :date
  end
end
