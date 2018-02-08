class CardHistoriesController < ApplicationController
    include CardProfileHelper
    def create
      card_history = nil
      ActiveRecord::Base.transaction do
        initial_profile = CardProfile.find(params[:card_profile_id])
        paramsn = params.permit( :certificate_valid_date,
                                 :new_or_renew,
                                 :card_valid_date,
                                 :new_approval_valid_date,
                                 :date_to_get_card,)
        CardProfile.find( params[:card_profile_id] ).update(paramsn)
        card_history = CardHistory.create(paramsn)
        card_history.update(card_profile_id: params[:card_profile_id])
        final_profile = card_history.card_profile
        attr =  ["date_to_get_card", "new_approval_valid_date", "card_valid_date", "certificate_valid_date", "new_or_renew"]
        attr.each do |a|
          if initial_profile[a] != final_profile[a] && get_section_by_field(a)
            CardRecord.create(
                key: get_section_by_field(a),
                action_type: get_action_type_by_fields(initial_profile[a], final_profile[a]),
                current_user_id: current_user.id,
                field_key: a,
                file_category: nil,
                value1: final_field_value(a,initial_profile[a]),
                value2: final_field_value(a,final_profile[a]),
                value: nil,
                card_profile_id: initial_profile.id)
          end
        end
        CardRecord.create(
            key: 'card_history_information',
            action_type: 'add',
            current_user_id: current_user.id,
            field_key: nil,
            file_category: nil,
            value1: nil,
            value2: nil,
            value: nil,
            card_profile_id: initial_profile.id)
      end
      response_json id:card_history.id  if card_history != nil
    end

    def update
      params.require(:id )
      history = CardHistory.find(params[:id])
      initial_profile = CardProfile.find(history.card_profile_id)
      paramsn = params.permit( :certificate_valid_date,
                               :new_or_renew,
                               :card_valid_date,
                               :new_approval_valid_date,
                               :date_to_get_card )
      history.update(paramsn)
      history.card_profile.update(paramsn) if history.is_valid_record?
      final_profile = history.card_profile
      attr =  ["date_to_get_card", "new_approval_valid_date", "card_valid_date", "certificate_valid_date", "new_or_renew"]
      attr.each do |a|
        if initial_profile[a] != final_profile[a] && get_section_by_field(a)
          CardRecord.create(
              key: get_section_by_field(a),
              action_type: get_action_type_by_fields(initial_profile[a], final_profile[a]),
              current_user_id: current_user.id,
              field_key: a,
              file_category: nil,
              value1: final_field_value(a,initial_profile[a]),
              value2: final_field_value(a,final_profile[a]),
              value: nil,
              card_profile_id: initial_profile.id)
        end
      end
      CardRecord.create(
          key: 'card_history_information',
          action_type: 'edit',
          current_user_id: current_user.id,
          field_key: nil,
          file_category: nil,
          value1: nil,
          value2: nil,
          value: nil,
          card_profile_id: initial_profile.id)
      response_json
    end

    def destroy
      params.require(:id)
      history = CardHistory.find(params[:id])
      initial_profile = CardProfile.find(history.card_profile_id)
      final_profile = history.card_profile
      history.destroy
      first_history = final_profile.card_histories.order('updated_at desc').first
      if first_history
        final_profile.update(
            date_to_get_card: first_history.date_to_get_card,
            new_approval_valid_date: first_history.new_approval_valid_date,
            card_valid_date:         first_history.card_valid_date,
            certificate_valid_date:  first_history.certificate_valid_date,
            new_or_renew:            first_history.new_or_renew
        )
      end
      attr = ["date_to_get_card", "new_approval_valid_date", "card_valid_date", "certificate_valid_date", "new_or_renew"]

      attr.each do |a|
        if initial_profile[a] != final_profile[a] && get_section_by_field(a)
          CardRecord.create(
              key: get_section_by_field(a),
              action_type: get_action_type_by_fields(initial_profile[a], final_profile[a]),
              current_user_id: current_user.id,
              field_key: a,
              file_category: nil,
              value1: final_field_value(a,initial_profile[a]),
              value2: final_field_value(a,final_profile[a]),
              value: nil,
              card_profile_id: initial_profile.id)
        end
      end

      CardRecord.create(
          key: 'card_history_information',
          action_type: 'delete',
          current_user_id: current_user.id,
          field_key: nil,
          file_category: nil,
          value1: nil,
          value2: nil,
          value: nil,
          card_profile_id: initial_profile.id)
      response_json
    end

  end
