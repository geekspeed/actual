namespace :app do
  
  namespace :build do
    desc "Create Super Admins"
    task :super_admins => :environment do
      sadmins = [
        {
          :first_name => "Luke", :last_name => "Raskino", 
          :email => "luke@crowdmixxlabs.com", :password => "Apptual123",
          :password_confirmation => "Apptual123"
        },
        {
          :first_name => "Pankaj", :last_name => "Bagwan", 
          :email => "pankaj@crowdmixxlabs.com", :password => "admin123",
          :password_confirmation => "admin123"
        }
      ]
      sadmins.each do |user|
        u = User.create(user)
        u.update_attribute("_super_admin", true)
        u.approve!
        u.confirm!
      end
    end
  end  
end