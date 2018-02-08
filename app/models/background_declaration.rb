# == Schema Information
#
# Table name: background_declarations
#
#  id                                                 :integer          not null, primary key
#  relative_criminal_record_detail                    :string
#  relative_business_relationship_with_suncity_detail :string
#  user_id                                            :integer
#  created_at                                         :datetime         not null
#  updated_at                                         :datetime         not null
#  have_any_relatives                                 :boolean
#  relative_criminal_record                           :boolean
#  relative_business_relationship_with_suncity        :boolean
#
# Indexes
#
#  index_background_declarations_on_user_id  (user_id)
#

class BackgroundDeclaration < ApplicationRecord
  belongs_to :user
  validates :have_any_relatives, inclusion: {in: [false, true]}
  validates :relative_criminal_record, inclusion: {in: [false, true]}
  validates :relative_business_relationship_with_suncity, inclusion: {in: [false, true]}

end
