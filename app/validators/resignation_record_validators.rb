module ResignationRecordValidators
  class ResignationRecordValidator < ActiveModel:: Validator
    def validate(record)
      if  record.notice_date > record.resigned_date
        record.errors[:base] << "離職通知日期(#{record.notice_date}) 晚於 最後僱用日期（#{record.resigned_date}）"
      end
      if  record.final_work_date > record.resigned_date
        record.errors[:base] << "最後工作日期(#{record.final_work_date}) 晚於 最後僱用日期（#{record.resigned_date}）"
      end
    end
  end
end