json.call helper, :id, :checked_out, :check_out_time
json.person { json.partial! "people/person_limited", person: helper.person }
json.check_in_time helper.created_at
json.help_request do
  json.partial! 'lair/help_requests/help_request',
                request: helper.current_assignment.help_request,
                current_assignment: false
end if current_assignment && !helper.current_assignment.nil?
