json.call helper, :id, :checked_out, :check_out_time
json.person do
  json.partial! "people/person_limited",
                person: helper.person,
                render_help_request: !defined?(render_help_request) || render_help_request
end unless defined?(render_person) && !render_person
json.check_in_time helper.created_at
json.help_request do
  json.partial! 'lair/help_requests/help_request',
                request: helper.current_assignment.help_request,
                render_helper: false
end unless (defined?(render_help_requests) && !render_help_requests) ||
  helper.current_assignment.nil?
