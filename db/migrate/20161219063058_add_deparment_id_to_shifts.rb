class AddDeparmentIdToShifts < ActiveRecord::Migration[5.0]
  def change
    add_reference :shifts, :department, index: true
  end
end
