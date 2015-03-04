json.data @shifts do |shift|
  json.partial! 'lair/shifts/shift', shift: shift
end
