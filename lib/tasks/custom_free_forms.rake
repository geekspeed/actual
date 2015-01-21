namespace :fix do
  desc "Deleting the inconsistent records from FreeForm"

  task :custom_free_forms => :environment do
    ProgramFreeForm.where(:section_id => nil).delete_all
  end

  task :purge_nav_links => :environment do
    ProgramNavLink.delete_all
  end
end