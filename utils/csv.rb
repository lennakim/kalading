require 'CSV'

asms = CSV.read 'auto_submodel_2013-11-28_08h43m20.csv', :headers => true, :encoding=>"UTF-8", :col_sep=>","

ams = CSV.read 'auto_model_2013-11-28_05h29m51.csv', :headers => true, :encoding=>"UTF-8", :col_sep=>","

File.open 'out.csv', 'wb' do |f|
	asms.each do |asm|
		selected_ams = ams.select { |am| am[0] == asm[5] }
		asm << selected_ams[0][2] << selected_ams[0][3]
		f.write CSV.generate_line asm
	end
end
