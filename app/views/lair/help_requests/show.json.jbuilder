json.data do
  json.partial! 'lair/help_requests/help_request',
                request: @request,
                current_assignment: true
end
