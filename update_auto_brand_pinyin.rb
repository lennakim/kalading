AutoBrand.each do |a|
	a.name_pinyin = PinYin.of_string(a.name)[0].capitalize
	a.save
end

AutoBrand.find_by(name: '����').update_attributes({name_pinyin: 'C'})
AutoBrand.find_by(name: '����').update_attributes({name_pinyin: 'C'})
AutoBrand.find_by(name: '��������').update_attributes({name_pinyin: 'C'})
