json.data @courses do |c|
  json.partial! "/courses/course", course: c
end
