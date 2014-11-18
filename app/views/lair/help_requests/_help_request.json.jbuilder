json.call(request, :id, :position, :course, :description, :location, :open, :created_at)
json.person { json.partial! 'people/person_limited', person: request.person }
