class EntryListsController < ApplicationController
  before_action :set_entry_list, only: [:update]
  before_action :set_user, only: [:create, :can_create]
  def can_create

    if params['operation'] == 'by_hr' ? true : TrainingService.is_can_be_absent(@user)
       entry_list = EntryList.new(user_id: @user.id, train_id: params[:train_id], registration_status: :department_registration, registration_time: Time.zone.now, creator_id: current_user.id, title_id: params[:title_id], is_can_be_absent: TrainingService.is_can_be_absent(User.find(@user)) )
       if entry_list.valid?
         render json: {can_create: true, type: nil}
       else
         render json: {can_create: true, type: 'params_error'}
       end
    else
      render json: {can_create: false, type: TrainingService.reason_for_can_not_be_absent(@user)}
    end
  end


  def create
    #authorize EntryList
    entry_list = EntryList.where(user_id: params[:user_id], train_id: params[:train_id]).first

    result = if entry_list &&  entry_list.registration_status == 'cancel_the_registration'
               entry_list.update(registration_status: 'staff_registration')
             else
               EntryList.where(train_id: params[:train_id], user_id: @user.id).destroy_all
               EntryList.create_with_params(params[:user_id], params[:title_id], params[:operation], current_user.id, params[:train_id] )
             end
    if result
      response_json result
    else
      response_json params ,error: true
    end
  end

  def update
    response_json @entry_list.update_with_params(params[:change_reason], params[:title_id], params[:operator], params[:edit_action])
  end

  def batch_update_and_to_final_lists
    authorize EntryList
    ActiveRecord::Base.transaction do
      create_tag, update_tag = 0, 0
      params[:update]&.each do |hash|
        if EntryList.find(hash['id']).update_by_hr(hash.permit(*EntryList.update_params))
          update_tag += 1
        end
      end
      params[:create]&.each do |id|
        entry_list = EntryList.find(id)
        single_cost =  cal_single_cost(entry_list.train, params[:create].count)
        final_list = FinalList.create!(user_id:entry_list.user_id, train_id: entry_list.train_id, entry_list_id: entry_list.id, cost: single_cost, train_result: :train_pass )
        final_list&.train_classes <<  entry_list&.title&.train_classes  if  entry_list&.title&.train_classes
        final_list&.train_classes&.each do |train_class|
          SignList.create!(user_id: entry_list.user_id, train_id: entry_list.train_id, train_class_id: train_class.id, sign_status: TrainingService.sign_status_when_creating(entry_list.user))
          Message.add_notification(Train.find(entry_list.train_id), 'join_final_list', entry_list.user_id)
        end
        #参加培训时，train 与　user 建立联系
        entry_list.train.users << entry_list.user
        if final_list.valid?
          create_tag += 1
        end
      end
      response_json ({
          create_tag: create_tag,
          update_tag: update_tag
      })
    end
  end

  private
  def set_user
    @user = User.find(params[:user_id])
  end

  def set_entry_list
    @entry_list = EntryList.find(params[:id])
  end

  def cal_single_cost(train, count)
    train.train_cost / count  rescue BigDecimal(0)
  end

end
