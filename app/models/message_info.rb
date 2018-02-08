# == Schema Information
#
# Table name: message_infos
#
#  id          :integer          not null, primary key
#  content     :string
#  target_type :string
#  namespace   :string
#  targets     :integer          is an Array
#  sender_id   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class MessageInfo < ApplicationRecord
        # 將ApplicationRecord存在 group方法，將 target_type的实例group改成gruops 	看情况，使用时换回group
	enum target_type: [:user, :groups, :global]
end
