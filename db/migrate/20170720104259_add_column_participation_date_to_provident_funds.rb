class AddColumnParticipationDateToProvidentFunds < ActiveRecord::Migration[5.0]
  def change
    add_column :provident_funds, :participation_date, :date
  end
end
