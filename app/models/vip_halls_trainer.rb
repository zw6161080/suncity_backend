# == Schema Information
#
# Table name: vip_halls_trainers
#
#  id                           :integer          not null, primary key
#  vip_halls_train_id           :integer
#  train_date_begin             :datetime
#  train_date_end               :datetime
#  length_of_training_time      :integer
#  train_content                :string
#  user_id                      :integer
#  train_type                   :string
#  number_of_students           :integer
#  total_accepted_training_time :integer
#  remarks                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_vip_halls_trainers_on_user_id             (user_id)
#  index_vip_halls_trainers_on_vip_halls_train_id  (vip_halls_train_id)
#
# Foreign Keys
#
#  fk_rails_d7a2029560  (vip_halls_train_id => vip_halls_trains.id)
#  fk_rails_e4d5a99f12  (user_id => users.id)
#

class VipHallsTrainer < ApplicationRecord

  belongs_to :vip_halls_train, :class_name => 'VipHallsTrain', :foreign_key => 'vip_halls_train_id'
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'

  enum train_type: { individual_training: 'individual_training',
                     group_training:      'group_training' }

  after_create :update_vip_halls_train
  after_update :update_vip_halls_train
  def update_vip_halls_train
    vip_halls_train = VipHallsTrain.find(self.vip_halls_train_id)
    vip_halls_train.training_minutes_available    = VipHallsTrainer
                                                        .where(vip_halls_train_id: self.vip_halls_train_id)
                                                        .pluck('length_of_training_time')
                                                        .sum
    vip_halls_train.training_minutes_accepted     = VipHallsTrainer
                                                        .where(vip_halls_train_id: self.vip_halls_train_id)
                                                        .pluck('total_accepted_training_time')
                                                        .sum
    vip_halls_train.training_minutes_per_employee = (vip_halls_train.training_minutes_accepted/vip_halls_train.employee_amount).to_i
    vip_halls_train.save!
  end

end
