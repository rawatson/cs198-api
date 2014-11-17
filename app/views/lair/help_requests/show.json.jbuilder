json.data do
  json.call(@request, :position, :course, :description, :location, :open)
  json.person { json.partial! 'people/person_limited', person: @request.person }
end
