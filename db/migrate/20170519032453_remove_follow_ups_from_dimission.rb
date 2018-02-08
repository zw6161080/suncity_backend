class RemoveFollowUpsFromDimission < ActiveRecord::Migration[5.0]
  def change
    remove_column :dimissions, :follow_ups, :jsonb
  end
end
