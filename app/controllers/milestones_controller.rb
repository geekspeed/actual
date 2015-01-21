class MilestonesController < ApplicationController
  before_filter :load_dependency

  def index
    @milestones = @pitch.milestones
    @tasks = []
    @pitch.tasks.group_by(&:milestone_id).each do |tasks|
      @tasks << sort_only_tasks(tasks[1])
    end
    @tasks = @tasks.flatten
    @milestone = Milestone.new
    @task = Task.new
    @workflows = Hash[@pitch.workflows.map{|w| [w.phase_name, w.id]}]
    @pitch_fields = @pitch.custom_fields.keys + ["Summary"]
    @program_events = @program.program_events.map{|e| [e.title, e.id]}
    render layout: "application_new_design"
  end

  def create
    @milestone = @pitch.milestones.build(params[:milestone])
    if @milestone.save
      #flash[:notice] = "Task created."
    else
      flash[:error] = "There are errors"
    end
    request.xhr? ? (render :json => true) : (redirect_to :action => :index)
  end

  def show
    @milestone = @pitch.milestones.where(id: params[:id]).first
    if request.xhr? == 0
      render layout: false
    else
      render layout: "application_new_design"
    end
  end

  def achieved
    @milestone = @pitch.milestones.find(params[:id])
    @milestone.achieved!
    redirect_to :action => :index
  end 

  def filter_tasks
    @milestones = @pitch.milestones
    if params[:milestone_id] == "all"
      sort_tasks(@milestones)
    else
      milestone = Milestone.where(id: params[:milestone_id]).first
      sort_tasks(milestone)
    end
    @milestone = Milestone.new
    @task = Task.new
    render :layout => false
  end

  def filter_by_order
    @milestones = @pitch.milestones
    unless params[:filter_order] == "chronological"
      @tasks1 = []
      @pitch.tasks.group_by(&:milestone_id).each do |tasks|
        @tasks1 << sort_only_tasks(tasks[1])
      end
      @tasks1 = @tasks1.flatten
    else
      sort_tasks(@milestones)
    end
    @milestone = Milestone.new
    @task = Task.new
    render :layout => false
  end

  def filter_tasks_by_date
    @milestones = @pitch.milestones
    time_period = Task.filter_period(params[:filter_period])
    @tasks = Task.in(milestone_id: @milestones.map(&:id)).where(:deadline => time_period).asc(:complete).asc(:deadline)
    @milestone = Milestone.new
    @task = Task.new
    render :action => :filter_tasks, :layout => false
  end

  def download_action_plan
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "Action Plan",               
              :layout => 'pdf.html.erb',
              :locals     => { 
                :pitch => @pitch,
                :program => @pitch.try(:program)
              },
              :margin => {
                :top      => '1.3in',
                :bottom   => '1.8in',
                :left     => '0.1in',
                :right    => '0.1in'
              },
              :header => {
                      :content => render_to_string(
                      :template   => 'layouts/pdf/header.html.erb',                
                      :layout     => 'layouts/pdf.html.erb',
                      :locals     => { 
                          :program => @pitch.try(:program)
                      },
                  )
                }, 
              :footer => {
                      :content => render_to_string(
                      :template   => 'layouts/pdf/footer.html.erb',                
                      :layout     => 'layouts/pdf.html.erb',
                      :locals     => { 
                          :program => @pitch.try(:program)
                      },
                  )
                }
      end
    end
  end
  
  def save_to_document
        wicked = WickedPdf.new
    
        # Make a PDF in memory
        pdf_file = wicked.pdf_from_string(
        ActionController::Base.new().render_to_string(
                :template   => 'milestones/download_action_plan.pdf.erb',
                :layout     => 'layouts/pdf.html.erb',
                :locals     => { 
                    :pitch => @pitch,
                :program => @pitch.try(:program)
                    
                } 
            ),
            :pdf => 'milestones/download_action_plan.pdf.erb',
            :layout => 'pdf.html.erb',
            :locals     => { 
                :pitch => @pitch,
                :program => @pitch.try(:program)
              },
              :margin => {
                :top      => '1.3in',
                :bottom   => '1.8in',
                :left     => '0.1in',
                :right    => '0.1in'
            },
            :header => {
                    :content => ActionController::Base.new().render_to_string(
                    :template   => 'layouts/pdf/header.html.erb',                
                    :layout     => 'layouts/pdf.html.erb',
                    :locals     => { 
                        :program => @pitch.try(:program)
                        
                    },
                )
              }, 
            :footer => {
                    :content => ActionController::Base.new().render_to_string(
                    :template   => 'layouts/pdf/footer.html.erb',                
                    :layout     => 'layouts/pdf.html.erb',
                    :locals     => { 
                        :program => @pitch.try(:program)
                        
                    },
                )
              }
        )
        description = Workspace.workspace_sementic("left_milestone","Milestones", @program) + "#{Time.now.strftime(" %d %B %Y")}"
        file_name = "#{@pitch.title}.pdf"
        FileUtils.mkdir_p("#{Rails.root.to_s}/tmp/milestones")
        File.open("#{Rails.root.to_s}/tmp/milestones/#{file_name}", "wb") do |f|
          f.write(pdf_file)
          @document = @pitch.documents.build(:description => description,:attachment => f)
          f.close()
        end
        File.chmod(0755,"#{Rails.root.to_s}/tmp/milestones//#{file_name}")

       @document.user = current_user
       if @document.save
          flash[:notice] = "Document saved successfully"
       else
        flash[:error] = "There are errors"
       end
       redirect_to :back
  end
  private

  def load_dependency
    @program = Program.find(params[:program_id])
    @pitch = @program.pitches.find(params[:pitch_id])
  end
  
  def sort_only_tasks(tasks)
    task_ids = tasks.map(&:id)
    tasks = Task.in(id: task_ids)
    task = tasks.where(:milestone_flag => true)
    task = task + tasks.where(:deadline.ne => nil, complete: false, :milestone_flag => false).asc(:deadline)
    task = task + tasks.where(:deadline => nil, complete: false, :milestone_flag => false)
    task = task + tasks.where(complete: true, :milestone_flag => false)
  end
  
  def sort_tasks(milestone)
    milestones = (milestone.is_a? Array) ? milestone : [milestone]
    tasks = Task.in(milestone_id: milestones.map(&:id))
    @tasks = tasks.where(:deadline.ne => nil, complete: false).asc(:deadline)
    @tasks = @tasks + tasks.where(:deadline => nil, complete: false)
    @tasks = @tasks + tasks.where(complete: true)
  end
end
