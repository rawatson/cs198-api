json.call(request, :id, :course, :description, :location, :open, :created_at)
json.position request.position if request.open
json.person { json.partial! 'people/person_limited', person: request.person }
json.helper do
  json.partial! 'lair/helpers/helper',
                helper: request.current_assignment.helper_checkin,
                current_assignment: false
end if current_assignment && !request.current_assignment.nil?
