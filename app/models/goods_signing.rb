# == Schema Information
#
# Table name: goods_signings
#
#  id                       :integer          not null, primary key
#  distribution_date        :datetime
#  goods_status             :string
#  user_id                  :integer
#  goods_category_id        :integer
#  distribution_count       :integer
#  distribution_total_value :decimal(15, 2)
#  sign_date                :datetime
#  return_date              :datetime
#  distributor_id           :integer
#  remarks                  :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_goods_signings_on_distributor_id     (distributor_id)
#  index_goods_signings_on_goods_category_id  (goods_category_id)
#  index_goods_signings_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_1862be2500  (goods_category_id => goods_categories.id)
#  fk_rails_21cf35658a  (distributor_id => users.id)
#  fk_rails_aca77da207  (user_id => users.id)
#

class GoodsSigning < ApplicationRecord

  include StatementAble

  belongs_to :user
  belongs_to :distributor, class_name: 'User', foreign_key: :distributor_id
  belongs_to :goods_category

  enum goods_status: { not_sign: 'not_sign',
                       employee_sign: 'employee_sign',
                       automatic_sign: 'automatic_sign',
                       returned: 'returned',
                       no_return_required: 'no_return_required' }

  scope :by_career_entry_date, -> (career_entry_date) {
    from = career_entry_date[:begin]
    to   = career_entry_date[:end]
    if from && to
      includes(user: :profile)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from ", from: from)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    elsif from
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
    elsif to
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }

  scope :by_goods_category, -> (name) {
    where(goods_category_id: GoodsCategory.where('chinese_name = :name OR english_name = :name', name: name).select(:id))
  }

  scope :by_distributor, -> (name) {
    where(distributor_id: User.where('chinese_name = :name OR english_name = :name', name: name).select(:id))
  }

  class << self

    def extra_joined_association_names
      [{user: [:department, :position, :profile]}, :goods_category, :distributor]
    end

    def goods_status_options
      [
          {key: 'not_sign',           chinese_name: '未簽收',   english_name: 'Not sign',           simple_chinese_name: '未签收'},
          {key: 'employee_sign',      chinese_name: '員工簽收', english_name: 'Employee sign',      simple_chinese_name: '员工签收'},
          {key: 'automatic_sign',     chinese_name: '自動簽收', english_name: 'Automatic sign',     simple_chinese_name: '自动签收'},
          {key: 'returned',           chinese_name: '已歸還',   english_name: 'Returned',           simple_chinese_name: '已归还'},
          {key: 'no_return_required', chinese_name: '無需歸還', english_name: 'No return required', simple_chinese_name: '无需归还'}
      ]
    end

    def goods_category_options
      GoodsCategory.where('distributed_count > 0')
    end

    def detail_by_id(id)
      GoodsSigning.includes(:goods_category).find(id)
    end

    def auto_update_goods_status
      GoodsSigning.all.where(goods_status: 'not_sign').each do |record|
        if (Time.zone.now - record.distribution_date) > 10.days
          record.goods_status = 'automatic_sign'
          record.sign_date    = Time.zone.now
          if record.save
            # 通知員工：「您的物品中有 2件 外套 在發放后10日內沒有被簽收，現已自動簽收」
            Message.add_notification(record,
                                     'automatic_signed',
                                     record.user_id,
                                     { distribution_count: record.distribution_count,
                                       goods_category: GoodsCategory.find(record.goods_category_id) })
          end
        end
      end
    end

  end

  # 當員工發放物品后，會通知員工：「黃維他 向您發放了 2件 外套，請於發放后10日內簽收」
  after_create :add_distribution_notification
  def add_distribution_notification
    Message.add_notification(self,
                             'distribution_notification',
                             self.user_id,
                             { distributor: User.find(self.distributor_id),
                                     distribution_count: self.distribution_count,
                                     goods_category: GoodsCategory.find(self.goods_category_id) } )
  end

  # 分发、员工签收、自动签收、编辑 4个动作会调用此方法
  # 员工签收、自动签收调用 save 方法后，会启动 after_update
  after_update :update_goods_category_three_counts
  def update_goods_category_three_counts
    goods_category = GoodsCategory.find(self.goods_category_id)
    goods_category.distributed_count = GoodsSigning
                                           .all
                                           .where(goods_category_id: self.goods_category_id)
                                           .sum(:distribution_count)
    goods_category.returned_count    = GoodsSigning
                                           .all
                                           .where(goods_category_id: self.goods_category_id)
                                           .where(goods_status: 'returned')
                                           .sum(:distribution_count)
    goods_category.unreturned_count  = GoodsSigning.all.where(goods_category_id: self.goods_category_id).where(goods_status: 'not_sign').sum(:distribution_count) +
                                       GoodsSigning.all.where(goods_category_id: self.goods_category_id).where(goods_status: 'employee_sign').sum(:distribution_count) +
                                       GoodsSigning.all.where(goods_category_id: self.goods_category_id).where(goods_status: 'automatic_sign').sum(:distribution_count)
    goods_category.save!
  end

  def get_xlsx_data_row
    record = self.as_json(include: [
        {user: {include: [:department, :position, :profile]}},
        :goods_category,
        :distributor
    ])
    one_record = {}
    one_record[:distribution_date] = record.dig('distribution_date').strftime('%Y/%m/%d')
    one_record[:goods_status]      = I18n.t('goods_signings.enum_goods_status.'+record.dig('goods_status'))
    one_record[:employee_id]       = record.dig('user.empoid')
    if I18n.locale==:en
      one_record[:employee_name]   = record.dig 'user.english_name'
      one_record[:department]      = record.dig 'user.department.english_name'
      one_record[:position]        = record.dig 'user.position.english_name'
    elsif I18n.locale==:'zh-CN'
      one_record[:employee_name]   = record.dig 'user.simple_chinese_name'
      one_record[:department]      = record.dig 'user.department.simple_chinese_name'
      one_record[:position]        = record.dig 'user.position.simple_chinese_name'
    else
      one_record[:employee_name]   = record.dig 'user.chinese_name'
      one_record[:department]      = record.dig 'user.department.chinese_name'
      one_record[:position]        = record.dig 'user.position.chinese_name'
    end
    one_record[:career_entry_date] = record.dig('user.profile.data.position_information.field_values.date_of_employment')
    if I18n.locale==:en
      one_record[:goods_category]  = record.dig 'goods_category.english_name'
    elsif I18n.locale==:'zh-CN'
      one_record[:goods_category]  = record.dig 'goods_category.simple_chinese_name'
    else
      one_record[:goods_category]  = record.dig 'goods_category.chinese_name'
    end
    one_record[:distribution_count_with_unit] = "#{record.dig('distribution_count')} #{record.dig('goods_category.unit')}"
    one_record[:distribution_total_value]     = record.dig('distribution_total_value').to_s
    if record.dig('sign_date')
      one_record[:sign_date]                  = record.dig('sign_date').strftime('%Y/%m/%d')
    else
      one_record[:sign_date]                  = ' '
    end
    if record.dig('return_date')
      one_record[:return_date]                = record.dig('return_date').strftime('%Y/%m/%d')
    else
      one_record[:return_date]                = ' '
    end
    if I18n.locale==:en
      one_record[:distributor] = record.dig 'distributor.english_name'
    elsif I18n.locale==:'zh-CN'
      one_record[:distributor] = record.dig 'distributor.simple_chinese_name'
    else
      one_record[:distributor] = record.dig 'distributor.chinese_name'
    end
    one_record[:remarks]       = record.dig 'remarks'
    one_record
  end

end
