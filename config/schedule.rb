# coding: utf-8
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever


# run `whenever --update-crontab` in command to update crontab

# every :dat, :at => '6:00am' do
#   runner "Profile.update_information"
# end
#5
every :day, :at => '06:01am' do
  runner 'MedicalTemplateSetting.auto_update'
end

#6
every :day, :at => '06:31am' do
  runner 'MedicalInsuranceParticipator.auto_update'
end
#10
every :day, :at => '00:01am' do
  runner 'LoveFund.update_love_fund'
end

#1: 考勤更新工作时间（every 1.hours）
every 1.hours do
  runner 'Attend.update_working_time'
end

#2: 更新蓝卡发短信（every :day, :at => '00:01am' ）
every :day, :at => '00:01am' do
  runner 'CardProfile.auto_send_message'
end

#3: 更新商品发短信（every :day, :at => '12:01am'）
every :day, :at => '12:01am' do
  runner 'GoodsSigning.auto_update_goods_status'
end

#4: 更新贵宾厅培训员工总数（every '0 0 1 * *' ）
every '0 0 1 * *' do
  runner 'VipHallsTrain.auto_update_employee_amount'
end





#7
every '0 0 * * *' do
  runner 'Punishment.auto_logout_profile_punishment'
end

#8
every :day, :at => '00:01am' do
  runner 'Train.execute_signing_up'
end

#9
every :day, :at => '00:01am' do
  runner 'Train.execute_registration_ends'
end



#11
every :day, :at => '00:01am' do
  runner 'PunchCardState.auto_update'
end

#12
every :day, :at => '10:30pm' do
  runner 'RosterModelState.auto_update'
end

#13
every :day, :at => '00:01am' do
  runner 'RosterModelState.update_current_week_no'
end

#20
every :day, :at => '00:01am' do
  runner 'ProfileService.location_for_all_user'
end

#21
every :month, :at => '00:01am' do
  runner 'SocialSecurityFundItem.generate_all(Time.zone.now - 1.month)'
end

# 22
every :day, :at => '00:01am' do
  runner 'Punishment.auto_send_notification_at_abolition_date'
end
