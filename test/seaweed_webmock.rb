require 'webmock'
include WebMock::API

def webmock_seaweed_write_url
  url = "http://#{URI.escape(SEAWEED_HOST)}:#{SEAWEED_WRITE_PORT}"
end

def webmock_seaweed_read_url
  url = "http://#{URI.escape(SEAWEED_HOST)}:#{SEAWEED_READ_PORT}"
end

def fake_seaweed_hash
  "1,aabbccdd112233"
end

def webmock_generate(method, url, body, content_type="application/json")
  stub_request(method, url)
    .to_return(body: body, status: 200, headers: { 'Content-Type' => content_type })
end

def webmock_seaweed_assign
  url = webmock_seaweed_write_url + "/dir/assign"
  return_data = {
    "count": 1,
    "fid": "#{fake_seaweed_hash}",
    "publicUrl": "#{webmock_seaweed_write_url}",
    "url": "#{webmock_seaweed_write_url}"
  }
  webmock_generate(:post, url, return_data.to_json.to_s)
end

def webmock_seaweed_lookup
  url = webmock_seaweed_write_url + "/dir/lookup?volumeId=1"
  return_data = {
    "volumeId" => "1",
    "locations" => [{
      "url" => webmock_seaweed_read_url,
      "publicUrl" => webmock_seaweed_read_url
      }]
    }
  webmock_generate(:get, url, return_data.to_json.to_s)
end

def webmock_get_seaweed_file
  url = "#{webmock_seaweed_read_url}/#{fake_seaweed_hash}"
  return_data = "test_send_to_seaweed"
  webmock_generate(:get, url, return_data, 'text/plain')
end

def webmock_get_seaweed_agreement_template_file
  url = "#{webmock_seaweed_read_url}/2,aabbccdd112233"
  return_data = File.read("#{Rails.root}/test/files/test_agreement_template.docx")
  webmock_generate(:get, url, return_data, 'text/plain')
end

def webmock_put_seaweed_file
  url = "#{webmock_seaweed_write_url}/#{fake_seaweed_hash}"
  return_data = {
    "error": "request Content-Type isn't multipart/form-data"
  }
  webmock_generate(:put, url, return_data.to_json.to_s)
end

def webmock_delete_seaweed_file
  url = "#{webmock_seaweed_read_url}/#{fake_seaweed_hash}"
  return_data = { "size" => 71 }
  webmock_generate(:delete, url, return_data.to_json.to_s)
end

def seaweed_webmock
  webmock_seaweed_assign
  webmock_seaweed_lookup
  webmock_put_seaweed_file
  webmock_get_seaweed_file
  webmock_delete_seaweed_file
end