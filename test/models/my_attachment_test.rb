require "test_helper"

class MyAttachmentTest < ActiveSupport::TestCase
  def my_attachment
    @my_attachment ||= MyAttachment.new
  end

  def _test_valid
    assert my_attachment.valid?
  end
  
  def test_by_search_key
    test_user =  create_test_user
    create(:my_attachment, user_id: test_user.id,  file_name: '2017-10-08').update_columns(created_at: '2017-12-12')
    create(:my_attachment, user_id: test_user.id,  file_name: 'abc').update_columns(created_at: '2017-12-12')
    create(:my_attachment, user_id: test_user.id,  file_name: 'abcd').update_columns(created_at: '2017-12-12')
    create(:my_attachment, user_id: test_user.id,  file_name: '2017/03/02').update_columns(created_at: '2017-12-12')
    create(:my_attachment, user_id: test_user.id,  file_name: '2017-06-03 12:17:30').update_columns(created_at: '2017-12-12')

    assert_equal  MyAttachment.by_query_key('2017-10-08').count, 1
    assert_equal  MyAttachment.by_query_key('abc').count, 2
    assert_equal  MyAttachment.by_query_key('abcd').count, 1
    assert_equal  MyAttachment.by_query_key('2017-12-12').count, 5
  end
end
