json.call(request, :id, :course, :description, :location, :open, :created_at)
json.position request.position if request.open
json.person { json.partial! 'people/person_limited', person: request.person }
