json.call person, :id, :first_name, :last_name, :nick_name, :sunet_id
json.help_requests person.help_requests.where open: true do |request|
  json.partial! 'lair/help_requests/help_request',
                request: request,
                render_person: false
end unless (defined?(render_help_requests) && !render_help_requests) || person.help_requests.empty?

json.courses_taking person.courses_taking do |course|
  json.partial! 'courses/course', course: course
end

json.courses_staffing person.courses_staffing do |course|
  json.partial! 'courses/course', course: course
end
