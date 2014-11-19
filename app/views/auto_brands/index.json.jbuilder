json.array! @auto_brands do |ab|
    json.name ab.name
    json.set! 'ams' do
        json.array! ab.auto_models.where(service_level: 1).asc(:name_pinyin).select { |am| am.auto_submodels.where(data_source: 2, service_level: 1).exists? } do |am|
            json.name am.name
            json.set! 'asms' do
                json.array! am.auto_submodels.where(data_source: 2, service_level: 1).asc(:name) do |asm|
                    json._id asm.id
                    json.name asm.name + ' '+ asm.engine_displacement + ' ' + asm.year_range
                end
            end
        end
    end
end