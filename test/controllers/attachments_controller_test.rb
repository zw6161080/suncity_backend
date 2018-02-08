require 'test_helper'

class AttachmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    seaweed_webmock
  end

  test "post create one attachment" do
    attachment_params = {
      file: fixture_file_upload('files/test_send_to_seaweed.txt')
    }

    assert_difference('Attachment.count', 1) do
      post "/attachments", params: attachment_params

      assert_nil json_res['data'].fetch('seaweed_hash', nil)
      assert_equal json_res['data']['file_name'], 'test_send_to_seaweed.txt'

      assert_response :ok
    end

    the_attach = Attachment.last.reload
    assert_equal the_attach.seaweed_hash, fake_seaweed_hash
  end

  test "post upload avatar" do
    attachment_params = {
      file: fixture_file_upload('files/test_send_to_seaweed.txt')
    }

    assert_difference('Attachment.count', 1) do
      post "/attachments/upload_avatar", params: attachment_params
      the_attach = Attachment.last.reload
      assert_equal json_res['data']['path'], "/avatar/#{fake_seaweed_hash}"

      assert_response :ok

      get json_res['data']['path']
      assert_equal response.header.fetch('X-Accel-Redirect'), "/internal/#{webmock_seaweed_read_url}/#{fake_seaweed_hash}?"
      # assert_equal response.header.fetch('X-Accel-Redirect'), "/internal?#{{url: "#{webmock_seaweed_read_url}/#{fake_seaweed_hash}"}.to_query}"
    end
  end
end
