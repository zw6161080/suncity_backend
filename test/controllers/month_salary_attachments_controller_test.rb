require "test_helper"

class MonthSalaryAttachmentsControllerTest < ActionDispatch::IntegrationTest
  def test_show
    msa = MonthSalaryAttachment.create(creator_id: create_test_user.id, status: :generating, report_type: :index)
    get month_salary_attachment_url({id: msa.id})
    assert_response :ok
    byebug
  end
end
