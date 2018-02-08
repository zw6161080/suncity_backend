module LoveFundHelper
  def beginning_of_next_day
    (Time.zone.now.midnight + 1.day)
  end

  def cal_cul_valid_date(valid_date)
      valid_date
  end
end