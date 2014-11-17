json.data @requests do |req|
  json.person { json.partial! 'people/person_limited', person: req.person }
  json.call(req, :id, :course, :created_at, :description, :location)
end
