json.data @requests do |req|
  json.partial! 'lair/help_requests/help_request', request: req
end
