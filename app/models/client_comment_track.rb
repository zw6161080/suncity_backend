# == Schema Information
#
# Table name: client_comment_tracks
#
#  id                :integer          not null, primary key
#  content           :string
#  user_id           :integer
#  track_date        :datetime
#  client_comment_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_client_comment_tracks_on_client_comment_id  (client_comment_id)
#  index_client_comment_tracks_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_2c7ce7204f  (user_id => users.id)
#  fk_rails_c759e27393  (client_comment_id => client_comments.id)
#

class ClientCommentTrack < ApplicationRecord
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :client_comment, :class_name => 'ClientComment', :foreign_key => 'client_comment_id'

  after_create :update_client_comment, :send_notification
  def update_client_comment
    comment = ClientComment.find(self.client_comment_id)
    comment.last_tracker_id    = self.user_id
    comment.last_track_date    = self.track_date
    comment.last_track_content = self.content
    comment.save!
  end

  def send_notification
    training_group_users = Role.find_by(key: 'training_group')&.users
    Message.add_notification(self,
                             'tracked_a_client_comment',
                             training_group_users.pluck(:id).uniq,
                             { employee: User.find(self.user_id) }) unless (training_group_users.nil? || training_group_users.empty?)
  end

  after_update :update_last_track_content
  def update_last_track_content
    comment = ClientComment.find(self.client_comment_id)
    comment.last_track_content = ClientCommentTrack
                                     .where(client_comment_id: comment.id)
                                     .order('track_date desc')
                                     .first.content
    comment.save!
  end

  after_destroy :reset_client_comment
  def reset_client_comment
    comment = ClientComment.find(self.client_comment_id)
    comment.last_tracker_id    = nil
    comment.last_track_date    = nil
    comment.last_track_content = nil
    target = ClientCommentTrack
                 .where(client_comment_id: comment.id)
                 .order('track_date desc')
                 .first
    if target
      comment.last_tracker_id    = target.user_id
      comment.last_track_date    = target.track_date
      comment.last_track_content = target.content
    end
    comment.save!
  end

end
