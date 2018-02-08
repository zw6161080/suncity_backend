class CreateClientCommentTracks < ActiveRecord::Migration[5.0]
  def change
    create_table :client_comment_tracks do |t|
      t.string     :content
      t.references :user, foreign_key: true, index: true
      t.datetime   :track_date
      t.references :client_comment, foreign_key: true, index: true

      t.timestamps
    end
  end
end
