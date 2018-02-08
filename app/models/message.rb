# coding: utf-8
class Message
  USER_TARGET = 'user'
  # USERS_TARGET = 'users'
  GROUP_TARGET = 'group'
  GLOBAL_TARGET = 'global'
  TASK_NAMESPACE = 'task'
  NOTIFICATION_NAMESPACE = 'notification'

  DEFAULT_SENDER = 'suncity-system'

  attr_accessor :target_type
  attr_accessor :namespace
  attr_accessor :target
  attr_accessor :targets
  attr_accessor :content
  attr_accessor :sender_id
  attr_accessor :targets

  def initialize
    @target_type ||= USER_TARGET
    @sender_id ||= DEFAULT_SENDER
  end

  def target=(target)
    @target = target
    @targets = [target]
  end

  # save message object to message server
  def save
    MessageService.create_message(self)
  end

  def self.save_one(namespace, object, action, target_user=nil, meta={})
    msg = self.new
    msg.namespace = namespace
    msg.content = {
      action: action,
      object: {
        type: object.class.to_s.underscore,
        id: object.id,
        meta: meta.merge(self.meta_of(object))
      }
    }.to_json

    if target_user.is_a?(Array)
      msg.targets = target_user
      msg.target_type = USER_TARGET
    elsif target_user.blank?
      msg.target_type = GLOBAL_TARGET
    else
      msg.target = target_user
      msg.target_type = USER_TARGET
    end

    msg.save
  end

  def self.add_task(object, action, target=nil, meta={})
    self.save_one(Message::TASK_NAMESPACE, object, action, target, meta)
  end

  def self.add_notification(object, action, target=nil, meta={})
    self.save_one(Message::NOTIFICATION_NAMESPACE, object, action, target, meta)
  end

  def self.meta_of(object)
    pending_status = {
        id: nil,
        chinese_name: '待定',
        english_name: 'Pending',
        simple_chinese_name: '待定'
    }
    target_position = object.applicant_position.position.attributes.slice('id', 'chinese_name', 'english_name') rescue pending_status
    target_department = object.applicant_position.department.attributes.slice('id', 'chinese_name', 'english_name') rescue pending_status
    case object.class.to_s.underscore.to_sym
    when :applicant_position
      {
        position: Hash(object.position.try(:attributes)).slice('id', 'chinese_name', 'english_name'),
        department: Hash(object.department.try(:attributes)).slice('id', 'chinese_name', 'english_name'),
        applicant_profile: object.applicant_profile.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :applicant_profile
      {
        applicant_profile: object.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :interview
      {
        interview: object.attributes.slice('id', 'time', 'mark', 'result'),
        applicant_position: object.applicant_position.attributes.slice('id'),
        position: target_position,
        department: target_department,
        applicant_profile: object.applicant_position.applicant_profile.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :audience
      {
        audience: object.attributes.slice('id', 'time', 'comment', 'status'),
        applicant_position: object.applicant_position.attributes.slice('id'),
        position: target_position,
        department: target_department,
        applicant_profile: object.applicant_position.applicant_profile.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :interviewer
      {
        interviewer: object.attributes.slice('id', 'status', 'comment'),
        interview: object.interview.attributes.slice('id', 'time', 'mark', 'result'),
        applicant_position: object.interview.applicant_position.attributes.slice('id'),
        position: target_position,
        department: target_department,
        applicant_profile: object.interview.applicant_position.applicant_profile.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :position
      {
        position: object.attributes.slice('id', 'chinese_name', 'english_name'),
        department: object.department.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :department
      {
        department: object.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :job
      {
        job: object.attributes.slice('id'),
        position: object.position.attributes.slice('id', 'chinese_name', 'english_name'),
        department: object.department.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :roster
      {
        roster: object.attributes.slice('id', 'from', 'to'),
        department: object.department.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :card_profile
      {
        card_profile: object.attributes.slice('id', 'empo_chinese_name', 'empo_english_name', 'approval_id')
      }
    when :staff_feedback_track
      {
        track: object.attributes
      }
    when :staff_feedback
      {
        feedback: object.attributes
      }
    when :goods_signing
      {
        goods_signing: object.attributes
      }
    when :client_comment
      {
        client_comment: object.attributes
      }
    when :client_comment_track
      {
        client_comment_track: object.attributes
      }
    when :punishment
      {
        punishment: object.attributes
      }
    when :questionnaire
      {
        questionnaire: object.attributes,
        user: object.user.attributes.slice('id', 'chinese_name', 'english_name'),
        template: object.questionnaire_template.attributes.slice('id', 'chinese_name', 'english_name'),
        release_user: object.release_user.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :entry_appointment
      {
        entry_appointment: object.attributes,
        user: object.user.attributes.slice('id', 'chinese_name', 'english_name'),
        template: QuestionnaireTemplate.find(object.questionnaire_template_id),
        inputter: object.inputter.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :dimission_appointment
      {
        dimission_appointment: object.attributes,
        user: object.user.attributes.slice('id', 'chinese_name', 'english_name'),
        template: QuestionnaireTemplate.find(object.questionnaire_template_id),
        inputter: object.inputter.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :dimission
      {
        dimission: object.attributes,
        user: object.user.attributes.slice('id', 'chinese_name', 'english_name')
      }
    when :appraisal
      {
        appraisal: object.attributes.slice('id', 'appraisal_name', 'date_begin', 'date_end')
      }
    when :train
      {
         train: object.attributes.slice('id', 'chinese_name', 'english_name', 'simple_chinese_name', 'train_number', 'train_date_begin', 'train_date_end')
      }
    when :roster_object
      {
        roster_object: object.attributes,
        user: object.user.attributes.slice('id', 'chinese_name', 'english_name', 'simple_chinese_name'),
      }
    when :attend_month_approval
      {
        attend_month_approval: object.attributes,
      }
    end
  end

end
