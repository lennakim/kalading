json.array! @auto_brands do |ab|
    json.name ab.name
    json._id ab.id
    json.initial ab.name_pinyin.chr.upcase
    json.logo ab.picture.p.url if ab.picture
    json.set! 'ams' do
        json.array! ab.auto_models.where(service_level: 1).asc(:name_pinyin).select { |am| am.auto_submodels.where(data_source: 2, service_level: 1).exists? } do |am|
            json.name am.name
            json._id am.id
            json.set! 'asms' do
                params[:city_id] = '5307033e098e719c45000043' if params[:city_id].blank?
                json.array! am.auto_submodels.where(data_source: 2, service_level: 1).asc(:name).select {|asm| !asm.cities.find(params[:city_id]).nil? } do |asm|
                  if params[:pm25].blank? || asm.parts.where(part_type_id: '522b2ed6098e713672000004', part_brand_id: '539d4d019a94e4de84000567').count > 0
                    json._id asm.id
                    json.name asm.name + ' '+ asm.engine_displacement + ' ' + asm.year_range
                  end
                end
            end
        end
    end
end