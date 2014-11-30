json.data @assignments do |a|
  json.partial! 'helper_assignment', assignment: a
end
