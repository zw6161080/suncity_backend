class AddReferenceToLentRecordsAndMuseumRecords < ActiveRecord::Migration[5.0]
  def change
    add_reference :lent_records, :career_record, index: true, foregin_key: true
    add_reference :museum_records, :career_record, index: true, foregin_key: true
  end
end
