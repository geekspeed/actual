class PitchWorkFlowController < ApplicationController
  
  before_filter :load_dependency
  
  
  def check_required_fields
    blank_fields = []
     custom_fields = Pitch.custom_fields_with_anchor("pitch").enabled
     custom_fields.where(program_id: @program.id, required: true).or({branch_id: nil}, {branch_id: @pitch.pitch_branch_id.to_s}).
                select{|field| field if Workflow.where(program_id: @program.id.to_s, active: true, :code.in => field.phases).present?}.
                each do |custom_field|
                  if @pitch.custom_fields.keys.include?(custom_field.code)
                    if @pitch.send(custom_field.code.to_sym).blank?
                      blank_fields << custom_field.label
                    end
                  else
                    blank_fields << custom_field.label
                  end
                end
    Resque.enqueue(App::Background::SubmitProject,current_user.try(:id) , @pitch.try(:id)) if blank_fields.blank?
    render :json => {:status => (blank_fields.blank? ? true : false), :blank_fields => blank_fields }.to_json
  end
  
  
  private

  def load_dependency
    @program = Program.find(params[:program_id])
    @pitch = @program.pitches.find(params[:pitch_id])
  end

end
