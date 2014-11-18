json.data do
  json.partial! 'lair/help_requests/help_request', request: @request
  json.person { json.partial! 'people/person_limited', person: @request.person }
end
