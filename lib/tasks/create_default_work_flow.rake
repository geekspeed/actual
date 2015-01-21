namespace :fix do
  desc "[seed] Creates default work flow"
  task :create_work_flow => :environment do
    
    Program.all.each do |prog|
      prog.workflows.create!(phase_name: "Submission deadline", program: prog,
                             applicable_role: "company_admin", tracking: "System",
                             help_text: "Stops editing of entries",
                             on: false, position: 6, change_role: false )
    end
  end
  
  task :project_sub_work_flow => :environment do
    
    Program.all.each do |prog|
      begin
        next if prog.workflows.where(code: "project_submission").try(:first)
        prog.workflows.where(:position.gte => 7, :position.ne => 9999).each do |work|
          work.update_attributes(position: work.position + 1) unless work.position == 9999 
        end
        prog.workflows.create!(phase_name: "Project Submission", program: prog,
                               applicable_role: "participant", tracking: "Status
                               Button", help_text: "Project Submission",
                               on: false, position: 7, undoable: true )
      rescue Exception => e
        log_file = File.open(Rails.root.to_s + '/log/project_sub_work_flow.log', 'a+')
        log_file.write("\n****************************#{Date.today}*********************************************\n")
        log_file.write("#{e.message}")
        log_file.write("#{prog.id}")
        log_file.flush
        next
      end
    end
  end
  
  task :change_order => :environment do
    
    Program.all.each do |prog|
      begin
        if prog.workflows.where(code: "project_submission").try(:first) and prog.workflows.where(code: "submission_deadline").try(:first)
          dead_line = prog.workflows.where(code: "submission_deadline").try(:first).try(:position)
          project_submit = prog.workflows.where(code: "project_submission").try(:first).try(:position)
          prog.workflows.where(code: "project_submission").try(:first).update_attributes(position: dead_line)
          prog.workflows.where(code: "submission_deadline").try(:first).update_attributes(position: project_submit )
        end
      rescue Exception => e
        log_file = File.open(Rails.root.to_s + '/log/change_order.log', 'a+')
        log_file.write("\n****************************#{Date.today}*********************************************\n")
        log_file.write("#{e.message}")
        log_file.write("#{prog.id}")
        log_file.flush
        next
      end
    end
  end
  
end
