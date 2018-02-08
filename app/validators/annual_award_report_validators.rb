module AnnualAwardReportValidators
  class GrantTypeRuleValidator < ActiveModel:: Validator
    def validate(record)
      keys = record.grant_type_rule.map {|hash| hash['key']}
      if record.annual_bonus_grant_type == 'all'
        record.errors[:base] << "The grant_type_rule is wrong value " unless keys == ['all']
      end

      if record.annual_bonus_grant_type == 'division_of_job'
        record.errors[:base] << "The grant_type_rule is wrong value " unless keys.sort ==  ['front_office', 'back_office'].sort
      end

      if record.annual_bonus_grant_type == 'departments'
        record.errors[:base] << "The grant_type_rule is wrong value " unless !keys.map(&:to_i).include?0
      end
    end
  end
end