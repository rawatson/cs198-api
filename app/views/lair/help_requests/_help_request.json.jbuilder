json.call(request, :id, :course, :description, :location, :open, :created_at, :updated_at)
json.position request.position if request.open
json.person do
  json.partial! 'people/person_limited', person: request.person,
                                         render_help_requests: false
end unless defined?(render_person) && !render_person
json.helper do
  json.partial! 'lair/helpers/helper',
                helper: request.current_assignment.helper_checkin,
                render_help_request: false
end unless (defined?(render_helper) && !render_helper) ||
  request.current_assignment.nil?
