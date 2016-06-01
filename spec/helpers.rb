def authorize_controller
  request.env['HTTP_AUTHORIZATION'] = "Basic #{Base64.encode64('GOOD')}"
end

def generate_headers(secret='GOOD')
  {
      'CONTENT_TYPE' => 'application/json',
      'Authorization' => "Basic #{Base64.encode64(secret)}"
  }
end

def json_response
  JSON.parse(response.body)
end

def expect_status(status)
  puts "\nREQUEST:\n#{request.body.string}\n\nRESPONSE:\n#{response.body}" unless response.status == status
  expect(response.status).to eql status
end

def expect_ok
  expect_status(200)
end

def expect_created
  expect_status(201)
end

def expect_bad_request(message_includes=nil)
  expect_error(status: 400, message_includes: message_includes)
end

def expect_not_authorized
  expect_status(401)
end

def expect_not_found
  expect_status(404)
end

def expect_not_allowed
  expect_status(405)
end

def expect_error(status: 400, message_includes: nil)
  expect_status(status)
  expect(response.body).to include(message_includes) if message_includes
end