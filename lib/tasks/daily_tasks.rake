# encoding: UTF-8

namespace :daily_tasks do
  task :clear_expired_videos => :environment do
    Video.where(:created_at.lte => DateTime.now.ago(3.months), :can_delete => true).destroy_all
  end
  
  task :all => [:clear_expired_videos]
end
