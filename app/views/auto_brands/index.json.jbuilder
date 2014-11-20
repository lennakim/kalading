json.array! @auto_brands do |ab|
    json.name ab.name
    json.set! 'ams' do
        json.array! ab.auto_models.where(service_level: 1).asc(:name_pinyin).select { |am| am.auto_submodels.where(data_source: 2, service_level: 1).exists? } do |am|
            json.name am.name
            json.set! 'asms' do
                json.array! am.auto_submodels.where(data_source: 2, service_level: 1).asc(:name) do |asm|
                  sm_valide = false
                  if params[:pm25].blank?
                    sm_valide = true
                  else
                    asm.parts.find_by(part_type_id: '522b2ed6098e713672000004', part_brand_id: '539d4d019a94e4de84000567') do |part|
                      if part.total_remained_quantity > 0
                        sm_valide = true
                        break
                      end
                    end
                  end
                  if sm_valide
                    json._id asm.id
                    json.name asm.name + ' '+ asm.engine_displacement + ' ' + asm.year_range
                  end
                end
            end
        end
    end
end