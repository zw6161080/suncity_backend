# coding: utf-8
# == Schema Information
#
# Table name: assessment_questionnaire_items
#
#  id                          :integer          not null, primary key
#  region                      :string
#  assessment_questionnaire_id :integer
#  chinese_name                :string
#  english_name                :string
#  simple_chinese_name         :string
#  group_chinese_name          :string
#  group_english_name          :string
#  group_simple_chinese_name   :string
#  order_no                    :integer
#  score                       :integer
#  explain                     :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  assessment_questionnaire_index  (assessment_questionnaire_id)
#

class AssessmentQuestionnaireItem < ApplicationRecord
  belongs_to :assessment_questionnaire

  def self.all_options_template
    self.normal_options_template + self.under_five_options_template + self.grade_five_options_template
  end

  def self.normal_options_template
    [
      {
        order_no: 17,
        chinese_name: '能將重點清楚明確地表達出來',
        english_name: 'Can expresse clearly',
        simple_chinese_name: '能将重点清楚明确地表达出来',
        group_chinese_name: '溝通能力',
        group_english_name: 'Communication skills',
        group_simple_chinese_name: '沟通能力'
      },
      {
        order_no: 18,
        chinese_name: '能把收到的訊息清晰地傳達他人',
        english_name: 'Can convey the message to others clearly',
        simple_chinese_name: '能把收到的讯息清晰地传达他人',
        group_chinese_name: '溝通能力',
        group_english_name: 'Communication skills',
        group_simple_chinese_name: '沟通能力'
      },
      {
        order_no: 19,
        chinese_name: '能配合他人，適當地調節自身的溝通模式',
        english_name: 'Can cooperate with others, appropriate to adjust their own communication mode',
        simple_chinese_name: '能配合他人，适当地调节自身的沟通模式',
        group_chinese_name: '溝通能力',
        group_english_name: 'Communication skills',
        group_simple_chinese_name: '沟通能力'
      },
      {
        order_no: 20,
        chinese_name: '適切表達自己的觀點，並能聆聽不同的意見',
        english_name: 'Appropriate to express their views, and can listen to different views',
        simple_chinese_name: '适切表达自己的观点，并能聆听不同的意见',
        group_chinese_name: '溝通能力',
        group_english_name: 'Communication skills',
        group_simple_chinese_name: '沟通能力'
      },

      {
        order_no: 21,
        chinese_name: '不斷提升工作品質',
        english_name: 'Continuously improve the quality of work',
        simple_chinese_name: '不断提升工作品质',
        group_chinese_name: '工作態度',
        group_english_name: 'Working attitude',
        group_simple_chinese_name: '工作态度'
      },
      {
        order_no: 22,
        chinese_name: '積極主動',
        english_name: 'Active',
        simple_chinese_name: '积极主动',
        group_chinese_name: '工作態度',
        group_english_name: 'Working attitude',
        group_simple_chinese_name: '工作态度'
      },
      {
        order_no: 23,
        chinese_name: '責任心強',
        english_name: 'Responsible',
        simple_chinese_name: '责任心强',
        group_chinese_name: '工作態度',
        group_english_name: 'Working attitude',
        group_simple_chinese_name: '工作态度'
      },
      {
        order_no: 24,
        chinese_name: '以專業和友善的態度提供服務',
        english_name: 'To provide services in a professional and friendly manner',
        simple_chinese_name: '以专业和友善的态度提供服务',
        group_chinese_name: '工作態度',
        group_english_name: 'Working attitude',
        group_simple_chinese_name: '工作态度'
      },

      {
        order_no: 25,
        chinese_name: '以禮貌和尊重的言行對待他人',
        english_name: 'Treat others with courtesy and respect',
        simple_chinese_name: '以礼貌和尊重的言行对待他人',
        group_chinese_name: '品德操守',
        group_english_name: 'Moral conduct',
        group_simple_chinese_name: '品德操守'
      },
      {
        order_no: 26,
        chinese_name: '尊重個人隱私，妥善保護公司及客戶的機密資訊',
        english_name: 'Respect personal privacy and protect confidential information from companies and customers',
        simple_chinese_name: '尊重个人隐私，妥善保护公司及客户的机密资讯',
        group_chinese_name: '品德操守',
        group_english_name: 'Moral conduct',
        group_simple_chinese_name: '品德操守'
      },
      {
        order_no: 27,
        chinese_name: '正直誠實、不散播謠言或惡意中傷',
        english_name: 'Honest, do not spread rumors or malicious slander',
        simple_chinese_name: '正直诚实、不散播谣言或恶意中伤',
        group_chinese_name: '品德操守',
        group_english_name: 'Moral conduct',
        group_simple_chinese_name: '品德操守'
      },
      {
        order_no: 28,
        chinese_name: '行事公平一致，能獲他人信任',
        english_name: 'Act in a fair and consistent manner and be trusted by others',
        simple_chinese_name: '行事公平一致，能获他人信任',
        group_chinese_name: '品德操守',
        group_english_name: 'Moral conduct',
        group_simple_chinese_name: '品德操守'
      }
    ]
  end

  def self.under_five_options_template
    [
      {
        order_no: 9,
        chinese_name: '遇到問題時能做出正確判斷及決策',
        english_name: 'Can make the right judgments and decisions when encounter problems',
        simple_chinese_name: '遇到问题时能做成正确判断及决策',
        group_chinese_name: '領導能力',
        group_english_name: 'Leadership',
        group_simple_chinese_name: '领导能力'
      },
      {
        order_no: 10,
        chinese_name: '被視為團隊成員仿效的榜樣',
        english_name: 'Be considered a model for team members to follow',
        simple_chinese_name: '被视为团队成员仿效的榜样',
        group_chinese_name: '領導能力',
        group_english_name: 'Leadership',
        group_simple_chinese_name: '领导能力'
      },
      {
        order_no: 11,
        chinese_name: '指導並幫助團隊成員充分發揮其潛能',
        english_name: 'Guide and help team members to fully realize their potential',
        simple_chinese_name: '指导并帮助团队成员充分发挥其潜能',
        group_chinese_name: '領導能力',
        group_english_name: 'Leadership',
        group_simple_chinese_name: '领导能力'
      },
      {
        order_no: 12,
        chinese_name: '有效激勵團隊成員工作的積極性',
        english_name: 'Effectively motivate team members to work',
        simple_chinese_name: '有效激励团队成员工作的积极性',
        group_chinese_name: '領導能力',
        group_english_name: 'Leadership',
        group_simple_chinese_name: '领导能力'
      },
      {
        order_no: 13,
        chinese_name: '可協助完成部門規劃工作',
        english_name: 'Can help complete the department planning work',
        simple_chinese_name: '可协助完成部门规划工作',
        group_chinese_name: '團隊管理',
        group_english_name: 'Team management',
        group_simple_chinese_name: '团队管理'
      },
      {
        order_no: 14,
        chinese_name: '按團隊成員的能力分配工作',
        english_name: 'According to the ability of team members to allocate work',
        simple_chinese_name: '按团队成员的能力分配工作',
        group_chinese_name: '團隊管理',
        group_english_name: 'Team management',
        group_simple_chinese_name: '团队管理'
      },
      {
        order_no: 15,
        chinese_name: '時常巡查工作地點及業務進度',
        english_name: 'Always check the workplace and business progress',
        simple_chinese_name: '时常巡查工作地点及业务进度',
        group_chinese_name: '團隊管理',
        group_english_name: 'Team management',
        group_simple_chinese_name: '团队管理'
      },
      {
        order_no: 16,
        chinese_name: '能準確分析團隊績效問題產生的原因',
        english_name: 'Can accurately analyze the causes of team performance problems',
        simple_chinese_name: '能准确分析团队绩效问题产生的原因',
        group_chinese_name: '團隊管理',
        group_english_name: 'Team management',
        group_simple_chinese_name: '团队管理'
      },
    ]
  end

  def self.grade_five_options_template
    [
      {
        order_no: 1,
        chinese_name: '無人監督下完成工作任務',
        english_name: 'Unsupervised to complete the task',
        simple_chinese_name: '无人监督下完成工作任务',
        group_chinese_name: '工作績效',
        group_english_name: 'Work Performance',
        group_simple_chinese_name: '工作绩效'
      },
      {
        order_no: 2,
        chinese_name: '熟練應用工作知識及技能',
        english_name: 'Proficient in applying knowledge and skills',
        simple_chinese_name: '熟练应用工作知识及技能',
        group_chinese_name: '工作績效',
        group_english_name: 'Work Performance',
        group_simple_chinese_name: '工作绩效'
      },
      {
        order_no: 3,
        chinese_name: '及時匯報問題和工作情況',
        english_name: 'Timely reporting of problems and work',
        simple_chinese_name: '及时汇报问题和工作情况',
        group_chinese_name: '工作績效',
        group_english_name: 'Work Performance',
        group_simple_chinese_name: '工作绩效'
      },
      {
        order_no: 4,
        chinese_name: '如期完成被安排的工作任務',
        english_name: 'Complete the scheduled tasks as scheduled',
        simple_chinese_name: '如期完成被安排的工作任务',
        group_chinese_name: '工作績效',
        group_english_name: 'Work Performance',
        group_simple_chinese_name: '工作绩效'
      },

      {
        order_no: 5,
        chinese_name: '嚴格遵守公司政策及規章制度',
        english_name: 'Strictly abide by company policies and rules and regulations',
        simple_chinese_name: '严格遵守公司政策及规章制度',
        group_chinese_name: '規則遵守',
        group_english_name: 'Rule compliance',
        group_simple_chinese_name: '规则遵守'
      },
      {
        order_no: 6,
        chinese_name: '嚴格遵守部門指引工作',
        english_name: 'Strictly comply with departmental guidelines',
        simple_chinese_name: '严格遵守部门指引工作',
        group_chinese_name: '規則遵守',
        group_english_name: 'Rule compliance',
        group_simple_chinese_name: '规则遵守'
      },
      {
        order_no: 7,
        chinese_name: '履行上級、部門主管委派之任務',
        english_name: 'Fulfill the tasks assigned by superiors and department heads',
        simple_chinese_name: '履行上级、部门主管委派址任务',
        group_chinese_name: '規則遵守',
        group_english_name: 'Rule compliance',
        group_simple_chinese_name: '规则遵守'
      },
      {
        order_no: 8,
        chinese_name: '行為舉止顧及公司之形象，維護公司聲譽',
        english_name: "Behavior to take into account the company's image, to maintain the company\'s reputation",
        simple_chinese_name: '行为举止顾及公司之形象、维护公司声誉',
        group_chinese_name: '規則遵守',
        group_english_name: 'Rule compliance',
        group_simple_chinese_name: '规则遵守'
      }
    ]
  end
end
