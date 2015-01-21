namespace :activity_feed do
  desc "Activity Feed Data Migration"
  task :data_migration => :environment do
    puts "\n\n[START] Migrating data of activity feed at #{Time.now}"
    ActivityFeed.all.each do |activity_feed|
      if activity_feed.type.blank? && activity_feed.community_feed_id.blank?
        puts "destroy"
        activity_feed.destroy
      end  
      if activity_feed.type=="community_feed" 
        puts "destroy"
        activity_feed.destroy
      end  
      if activity_feed.community_feed_id.blank?
        program = activity_feed.program
        if !program.blank?
          if activity_feed.type == "pitch_create"
            pitch = Pitch.where(:id=>activity_feed.pitch_id).try(:first)
            if pitch.blank?
              puts "destroy Pitch Activity"
              activity_feed.destroy
            else
              puts "Community Feed Create pitch create"
              community_feed = CommunityFeed.create!(:organisation_id => program.organisation.id , :program_id => program.id, :activity => true, :post_to=> "all", :created_by_id=> pitch.user_id, :created_at => activity_feed.created_at, :updated_at => activity_feed.updated_at)          
              activity_feed.community_feed_id = community_feed.id
              activity_feed.save
            end
          else
            puts "Community Feed Create"
            community_feed = CommunityFeed.create!(:organisation_id => program.organisation.id , :program_id => program.id, :activity => true, :post_to=> "all", :created_by_id=> activity_feed.user_id, :created_at => activity_feed.created_at, :updated_at => activity_feed.updated_at)  
            activity_feed.community_feed_id = community_feed.id
            activity_feed.save
          end
        else
          activity_feed.destroy
        end
      end
      puts "Activity Feed ID = "+activity_feed.id
    end 
    puts "[END] Migrating data of activity feed at #{Time.now}\n\n"
  end
end