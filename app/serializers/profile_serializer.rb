class ProfileSerializer < ActiveModel::Serializer
  attributes :id,
             :user_id,
             :region,
             :data
  has_one :provident_fund
end