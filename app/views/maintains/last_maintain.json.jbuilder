params[:info].split(',').each do |info_type|
  json.set! info_type, @maintain? @maintain.send(info_type) : ""
end