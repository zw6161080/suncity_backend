class CardAttachmentsController < ApplicationController
  include CardProfileHelper

  def create
    attachment = nil
    ActiveRecord::Base.transaction do
      paramsn = params.permit( :attachment_id,
                               :category,
                               :file_name,
                               :comment,
                               :card_profile_id,)
      attachment = CardAttachment.create(paramsn)
      attachment.update(operator_id: current_user.id)
      CardRecord.create(
          key: 'card_attachment_information',
          action_type: 'add',
          current_user_id: current_user.id,
          field_key: nil,
          file_category: nil,
          value1: single_field_to_multi_language_hash(attachment.category),
          value2: single_field_to_multi_language_hash(attachment.file_name),
          value: nil,
          card_profile_id: params[:card_profile_id]
      )
    end
    response_json id: attachment.id  if attachment != nil
  end

  def update
    params.require(:id )
    initial_attachment = CardAttachment.find(params[:id])
    paramsn = params.permit( :attachment_id,
                             :category,
                             :file_name,
                             :comment,)
    final_attachment = CardAttachment.find(params[:id])
    final_attachment.update(paramsn)
    final_attachment.update(operator_id: current_user.id)
    attr = ['operator_id', 'category', 'file_name', "comment"]
    value = []
    attr.each do |a|
      if initial_attachment[a] != final_attachment[a]
        if a == 'operator_id'
          initial_operator = User.find(initial_attachment[a])  rescue nil
          final_operator = User.find(final_attachment[a]) rescue nil
          value.push({
                         column_name: a,
                         old_value: {
                             chinese_name: initial_operator.try(:chinese_name),
                             simple_chinese_name: initial_operator.try(:simple_chinese_name),
                             english_name: initial_operator.try(:english_name),

                         },
                         new_value: {
                             chinese_name: final_operator.try(:chinese_name),
                             simple_chinese_name: final_operator.try(:simple_chinese_name),
                             english_name: final_operator.try(:chinese_name)

                         }

                     })
        else
          value.push({
                         column_name: a,
                         old_value: final_attachment_field_value(a,initial_attachment[a]),
                         new_value: final_attachment_field_value(a, final_attachment[a])
                     })
        end

      end
    end
    CardRecord.create(
        key: 'card_attachment_information',
        action_type: 'edit',
        current_user_id: current_user.id,
        field_key: nil,
        file_category: nil,
        value1: nil,
        value2: nil,
        value: value,
        card_profile_id: params[:card_profile_id]
    )
    response_json
  end

  def destroy
    params.require(:id)
    attachment = CardAttachment.find(params[:id])
    ActiveRecord::Base.transaction do
    CardRecord.create(
        key: 'card_attachment_information',
        action_type: 'delete',
        current_user_id: current_user.id,
        field_key: nil,
        file_category: nil,
        value1: single_field_to_multi_language_hash(attachment.category),
        value2: single_field_to_multi_language_hash(attachment.file_name),
        value: nil,
        card_profile_id: params[:card_profile_id]
    )
    attachment.destroy
    response_json
    end

  end


end
