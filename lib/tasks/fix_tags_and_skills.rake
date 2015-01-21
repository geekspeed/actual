namespace :fix do
  desc "[FIX] fixes tags and skills for user, feed and pitch"
  task :tag_attributes => :environment do
    puts "[START] User"
    User.in(skills: ["[]", "", " "]).each do |u|
      u.update_attribute(:skills, [])
    end
    puts "[END] User"

    puts "[START] Pitch"
    Pitch.in(skills: ["[]", "", " "]).each do |u|
      u.update_attribute(:skills, [])
    end
    puts "[END] Pitch"

    puts "[START] CommunityFeed"
    CommunityFeed.in(tags: ["[]", "", " "]).each do |u|
      u.update_attribute(:tags, [])
    end
    puts "[END] CommunityFeed"
  end
end