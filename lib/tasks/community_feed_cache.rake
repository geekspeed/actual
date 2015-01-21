namespace :app do
  namespace :community_feed do
    desc "Resets cache for community feed at program level"
    task :reset_cache => :environment do
      puts "[START] Resetting cache for community_feed"
      Program.all.each do |program|
        program_id = program.id.to_s
        puts "Adding for Program:#{program_id}"

        key = CommunityFeed.redis_key("program", program_id)
        #RESET current keys
        $redis.del(key)
        ids = CommunityFeed.for_program(program_id).pluck(:id)
        ids.collect{|id| $redis.sadd(key, id.to_s)}
        puts "\t   IDs to be stored: #{ids.inspect}"
        puts "\t   IDs stored: #{$redis.smembers(key)}"
      end
      # Pitch.all.each do |pitch|
      #   pitch_id = pitch.id.to_s
      #   puts "Adding for Pitch:#{pitch_id}"
      #   CommunityFeed::POST_TO.each do |post_to|
      #     puts "\tPost_to:#{post_to}"
      #     key = CommunityFeed.redis_key("pitch", pitch_id, post_to)
      #     #RESET current keys
      #     $redis.del(key)
      #     ids = CommunityFeed.for_pitch(pitch_id).where(
      #       :post_to.in => [post_to]).pluck(:id)
      #     ids.collect{|id| $redis.sadd(key, id.to_s)}
      #     puts "\t   IDs to be stored: #{ids.inspect}"
      #     puts "\t   IDs stored: #{$redis.smembers(key)}"
      #   end
      # end
      puts "[END] Resetting cache for community_feed"
    end
  end
end