require 'mongoid'
require 'devise'
require 'mongoid_paperclip'
require 'mongoid-history'
require 'kaminari'

load 'config/environment.rb'
load 'config/boot.rb'
load 'app/models/auto_brand.rb'
load 'app/models/auto_model.rb'
load 'app/models/auto_submodel.rb'

puts AutoBrand.first.name