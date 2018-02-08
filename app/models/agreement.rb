# == Schema Information
#
# Table name: agreements
#
#  id            :integer          not null, primary key
#  title         :string
#  attachment_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  region        :string
#
# Indexes
#
#  index_agreements_on_attachment_id  (attachment_id)
#

class Agreement < ApplicationRecord
  belongs_to :attachment

  scope :of_region, ->(region_key) { where(region: region_key) }

  attr_accessor :data

  def self.manila_files
    {
      temp_1: '1. (Blank)新員工到職通知書 Notification for New Join Staff',
      temp_2: '2. (Blank) 薪金協議書 Salary Aggreement2',
      temp_3: '3. (Blank) 新入職員工資料確認 Non Local-Compensation Package Confirmation',
      temp_4: '4. (Blank) 合約 Contract',
      temp_5: '5. (Blank) 競業禁止協議書 NON-COMPETITION AGREEMENT',
      temp_6: '6-1 (Bank)工作守則',
      temp_7: '6-2 (Blank) 交通守則',
      temp_8: 'NC01 (Blank) 員工簽約注意事項',
      temp_9: 'NC02-背景调查表Reference check form',
      temp_10: 'NC03 (Blank) 家屬成員申報表',
      temp_11: 'NC04 (Blank) 利益衝突申報書 Declaration Of Conflict Interest',
      temp_12: 'NC06 (Blank) 員工物資簽收表 Company Property Check List(Update)'
    }
  end

  def self.macau_files
    if I18n.locale == :'en-US'
    {
      temp_1: '(博彩中介) - 1-3級管理層加班協議書',
      temp_2: '(博彩中介) - 員工工作守則協議書',
      temp_3: '(博彩中介) - 交通事故責任處理協議書',
      temp_4: 'HR-FM-050 背景调查表Reference check form',
      temp_5: 'HR-FM-064-利益衝突申報書',
      temp_6: 'Macau＿Cover Page',
      temp_7: '太陽城人愛心基金參與表格HR-FM-037',
      temp_8: '博彩中介(外地僱員) - 貴賓廳,賬房,客戶服務部, 會籍部, 市場部',
      temp_9: '博彩中介(本地僱員) - 貴賓廳,賬房,客戶服務部, 會籍部, 市場部',
      temp_10: '員工簽約注意事項',
      temp_11: '公司物品簽收表HR-FM-037',
      temp_12: '家屬成員申報表HR-FM-041'
    }
    elsif I18n.locale == :'zh-CN'
    {
      temp_1: '(博彩中介) - 1-3級管理层加班协议书',
      temp_2: '(博彩中介) - 员工工作守则协议书',
      temp_3: '(博彩中介) - 交通事故责任处理协议书',
      temp_4: 'HR-FM-050 背景调查表Reference check form',
      temp_5: 'HR-FM-064-利益冲突申报书',
      temp_6: 'Macau＿Cover Page',
      temp_7: '太阳城人爱心基金参与表格HR-FM-037',
      temp_8: '博彩中介(外地雇员) - 贵宾厅,帐房,客户服务部, 会籍部, 市场部',
      temp_9: '博彩中介(本地雇员) - 贵宾厅,帐房,客户服务部, 会籍部, 市场部',
      temp_10: '员工签约注意事項',
      temp_11: '公司物品签收表HR-FM-037',
      temp_12: '家属成员申报表HR-FM-041'
    }
    else
    {
      temp_1: '(博彩中介) - 1-3級管理層加班協議書',
      temp_2: '(博彩中介) - 員工工作守則協議書',
      temp_3: '(博彩中介) - 交通事故責任處理協議書',
      temp_4: 'HR-FM-050 背景调查表Reference check form',
      temp_5: 'HR-FM-064-利益衝突申報書',
      temp_6: 'Macau＿Cover Page',
      temp_7: '太陽城人愛心基金參與表格HR-FM-037',
      temp_8: '博彩中介(外地僱員) - 貴賓廳,賬房,客戶服務部, 會籍部, 市場部',
      temp_9: '博彩中介(本地僱員) - 貴賓廳,賬房,客戶服務部, 會籍部, 市場部',
      temp_10: '員工簽約注意事項',
      temp_11: '公司物品簽收表HR-FM-037',
      temp_12: '家屬成員申報表HR-FM-041'
    }
    end
  end

  def self.generate_file(region, file, the_data, applicant_position_id)
    path = self.input_path(region, file)
    output_path = self.default_output_file_path
    template = Sablon.template(path)
    template.render_to_file(output_path, the_data)
    file_name = self.attachment_file_name(region, file, applicant_position_id)
    attachment = save_to_attachment(output_path, file_name)
  end

  def self.input_path(region, file)
    path = "#{Rails.root}/tmp/agreement_templates/#{region}/"
    path += self.try("#{region}_files").to_h.fetch(file.to_sym, '')
    path += '.docx'
  end

  # temporary copy
  def self.default_output_file_path
    "#{Rails.root}/tmp/agreement_templates/output/#{Time.zone.now.strftime('%Y%m%d')}-#{SecureRandom.hex(8)}.docx"
  end

  def self.attachment_file_name(region, file, applicant_position_id)
    applicant_profile_chinese_name = ApplicantPosition.find(applicant_position_id).applicant_profile.chinese_name
    tmp_name = self.try("#{region}_files").to_h.fetch(file.to_sym, '')
    "#{applicant_profile_chinese_name}-#{tmp_name}-#{Time.zone.now.strftime('%Y%m%d')}.docx"
  end

  def generate_agreement_file
    if data
      path = get_template_path
      output_path = output_file_path
      template = Sablon.template(path)
      template.render_to_file(output_path, data)
      attachment = self.class.save_to_attachment(output_path)
      save_to_main_record(attachment)
    else
      false
    end
  end

  AgreementAttachmentFile = Struct.new(:path)

  def self.save_to_attachment(path, file_name='')
    attachment = Attachment.new
    attachment.file_name = file_name
    attachment.seaweed_hash = Attachment.save_file_to_seaweed(path)
    attachment.file = AgreementAttachmentFile.new(path)
    attachment.save
    attachment
  end

  def get_template_path
    if !File.file?(template_path)
      open(template_path, 'wb') do |file|
        file.write attachment.read_file.body
      end
    end
    template_path
  end

  def template_path
    "#{self.class.template_dir}/#{attachment.seaweed_hash}.docx"
  end

  #abstract method, must be rewrited
  def output_file_path
    raise LogicError, { message: "Save agreement failed!" }.to_json
  end

  #abstract method, must be rewrited
  def save_to_main_record(args)
    raise LogicError, { message: "Save agreement failed!" }.to_json
  end

  def self.template_dir
    "#{Rails.root}/tmp/agreement_templates"
  end

end
