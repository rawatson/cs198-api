json.data @requests do |req|
  json.person { json.partial! 'people/person_limited', person: req.person }
  json.partial! 'lair/help_requests/help_request', request: req
end
