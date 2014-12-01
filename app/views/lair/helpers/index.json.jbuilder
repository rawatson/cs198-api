json.data @helpers do |h|
  json.partial! "helper", helper: h, current_assignment: true
end
