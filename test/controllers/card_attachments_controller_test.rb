require 'test_helper'

class CardAttachmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_user = create(:user)
    CardAttachmentsController.any_instance.stubs(:current_user).returns(@current_user)
  end

  test 'card attachment create' do
    profile = create(:card_profile)
    attachment = create(:attachment)
    user= create(:user)
    post "/card_attachments",params: {attachment_id:attachment.id,
                                    category:'passport',
                                    file_name:'2117,jpg',
                                    card_profile_id:profile.id,
                                      user_id:user.id
    }
    assert_response :ok
    assert_equal 'passport', CardAttachment.first.category
    assert_equal 1, CardRecord.count
  end

  test 'card attachment update' do
    profile = create(:card_profile)
    attachment = create(:card_attachment, card_profile_id: profile.id )
    patch "/card_attachments/#{attachment.id}",params: {attachment_id:100,
                                                category:'passport',
                                                file_name:'2000,aa', }
    assert_response :ok
    assert_equal 100, CardAttachment.first.attachment_id
    assert_equal 'passport', CardAttachment.first.category
    assert_equal '2000,aa', CardAttachment.first.file_name
    assert_equal 1, CardRecord.count
  end

  test 'card attachment destroy' do
    attachment = create(:attachment)
    card_attachment = create(:card_attachment)
    card_attachment.update(attachment_id: attachment.id, card_profile_id: create(:card_profile).id)
    create(:card_attachment)
    delete "/card_attachments/#{card_attachment.id}"
    assert_response :ok
    assert_equal 1, CardAttachment.count
  end
end
