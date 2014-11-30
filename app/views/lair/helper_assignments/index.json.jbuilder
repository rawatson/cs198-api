json.data @assignments do |a|
  json.partial! 'lair/helper_assignments/helper_assignment', assignment: a
end
