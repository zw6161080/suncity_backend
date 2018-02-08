class EntryListService
  class << self
    def get_registration_status(operation)
      case operation
        when  'by_employee', 'by_hr'
          :staff_registration
        when  'by_department'
          :department_registration
        when 'by_invited'
          :invitation_to_be_confirmed
      end
    end
  end
end