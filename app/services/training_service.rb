# coding: utf-8
class TrainingService
  class << self
    def train_info(user)
      {
          total_training_credits: total_training_credits(user),
          training_attend_percentage: training_attend_percentage(user),
          passing_trainning_percentage: passing_training_percentage(user),
          is_can_be_absent: is_can_be_absent(user),
          trains: user.trains.where(status: :completed).as_json(include: [:exam_template, :train_template_type], methods: {train_template: nil, calcul_single_cost: user, calcul_attend_percentage: user, calcul_test_score: user, calcul_train_result: user })
      }
    end


    def total_training_credits(user)
      user.trains.where(status: :completed).sum("training_credits")
    end

    def training_attend_percentage(user)
      sum = BigDecimal(0)
      user.trains.where(status: :completed) do |train|
        sum += calcul_attend_percentage(train, user)
      end
      sum / user.trains.where(status: :completed).count
    end


    def passing_training_percentage(user)
      BigDecimal(passing_counts_for_train(user)) / total_count_for_train(user) rescue BigDecimal(0)
    end

    #user: 一个员工通过培训的数量
    def passing_counts_for_train(user)
      user.trains.where(status: :completed).joins(:final_lists).where(final_lists: {user_id: user.id, train_result: :train_pass}).count
    end

    #user: 一个员工完成培训的数量
    def total_count_for_train(user)
      user.trains.where(status: :completed).count
    end

    def is_can_be_absent(user)
      !(user.training_absentees.where(has_been_exempted: false).count > 0)
    end

    #未豁免缺席原因; 使用前提 is_can_be_absent 的 值为false
    def reason_for_can_not_be_absent(user)
      if user.training_absentees.where(absence_reason: nil).count > 0
        'no_reason'
      else
        'not_exempted'
      end
    end

    def calcul_single_cost(train, user)
      FinalList.where(train_id: train.id, user_id: user.id).first&.cost
    end

    def calcul_attend_percentage(train, user)
      BigDecimal(attend_sign_list_count_for_train(train, user)) / sign_list_count_for_train(train, user) rescue BigDecimal(0)
    end

    #user: 一个员工该培训的总签到数
    def  sign_list_count_for_train(train, user)
      SignList.where(train_id: train.id, user_id: user.id).count
    end

    #user: 一个员工该培训出席的签到数
    def  attend_sign_list_count_for_train(train, user)
      SignList.where(train_id: train.id, user_id: user.id, sign_status: :attend).count
    end

    def calcul_test_score(train, user)
      TrainingPaper.where(train_id: train.id, user_id: user.id).first&.score
    end

    def calcul_train_result(train, user)
      FinalList.where(train_id: train.id, user_id: user.id).first&.train_result == 'train_pass'
    end
    #status1: 已公布;报名中;报名结束 :「有資格參加」＋「報名名單」
    def trains_in_status1(user)
      if  user.is_a? ActiveRecord::Relation
        Train.where(status: %w(has_been_published signing_up registration_ends)).map do |item|
          item.id if item.can_join_train.where(id: user.ids).count > 0
        end.compact
      else
        Train.where(status: %w(has_been_published signing_up registration_ends)).map do |item|
          item.id if item.can_join_train.where(id: user.id).count > 0
        end.compact
      end
    end

    #status2: 培训中;已完成
    #user.trains

    #status3: 已取消：报名名单
    def trains_in_status3(user)
      if  user.is_a? ActiveRecord::Relation
        Train.where(status: :cancelled).map do |item|
          item.id if item.entry_lists.where(user_id: user.ids).count > 0
        end.compact
      else
        Train.where(status: :cancelled).map do |item|
          item.id if item.entry_lists.where(user_id: user.id).count > 0
        end.compact
      end

    end

    def sign_status_when_creating(user)
      if ProfileService.is_leave?(user)
        'absence'
      else
        nil
      end
    end
  end
end
