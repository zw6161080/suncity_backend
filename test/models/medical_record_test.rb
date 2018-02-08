require "test_helper"

class MedicalRecordTest < ActiveSupport::TestCase
  def medical_record
    @medical_record ||= MedicalRecord.new
  end

  def test_valid
    assert medical_record.valid?
  end
end
