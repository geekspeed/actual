class TargettingsController < ApplicationController
  
  layout :false, :only => [:preview]
  
  def new
    @targettings = []
    @targettings << context_program.targettings.where(:is_default => true)
    @targettings << context_program.targettings.where(:is_default.ne => true)
    @targettings = @targettings.flatten
    @targetting = Targetting.new
  end

  def create
    @targetting = context_program.targettings.build(params[:targetting])
    if @targetting.save
      flash[:notice] = "Target Successfully saved"
      redirect_to  new_targettings_path
    else
      flash[:notice] = "Target not saved"
      redirect_to  new_targettings_path
    end
  end

  def edit
    @targetting = context_program.targettings.where(id: params[:id]).first
  end

  def destroy
    @targetting = context_program.targettings.where(id: params[:id]).first
    if @targetting.destroy
      flash[:notice] = "Target destroyed successfully"
      redirect_to  new_targettings_path
    else
      flash[:notice] = "Target could not be destroyed."
      redirect_to  new_targettings_path
    end
  end
  
  def update
    @targetting = context_program.targettings.where(id: params[:target_id]).first
    if @targetting.update_attributes(params[:targetting])
      flash[:notice] = "Target Updated Successfully"
      redirect_to  new_targettings_path
    else
      flash[:notice] = "Target not updated"
      redirect_to  new_targettings_path
    end
  end

  def preview
    unless params[:targetting][:role] == "pitch"
      @type = "user"
      users = User.in("_#{params[:targetting][:role]}" =>  context_program.id.to_s).map(&:id).map(&:to_s)
      if params[:targetting][:project_phase_achived].present?
        @pitches = context_program.workflows.where(:code => params[:targetting][:project_phase_achived]).present? ? context_program.workflows.where(:code => params[:targetting][:project_phase_achived]).first.pitch_phases.map(&:pitch).uniq : nil
        if @pitches.present?
          @pitch_users = @pitches.map(&:mentors).flatten.uniq
          @pitch_users << @pitches.map(&:members).flatten.uniq
          @pitch_users << @pitches.map(&:collaboraters).flatten.uniq
          @pitch_users << @pitches.map(&:user_id)
          users = users & (@pitch_users.flatten.uniq.map(&:to_s))
        else
          users = []
        end
      end
      if params[:targetting][:project_phase_not_achived].present?
        @pitches = context_program.workflows.where(:code => params[:targetting][:project_phase_not_achived]).present? ? context_program.workflows.where(:code => params[:targetting][:project_phase_not_achived]).first.pitch_phases.map(&:pitch).uniq : nil
        if @pitches.present?
          @pitch_users = @pitches.map(&:mentors).flatten.uniq
          @pitch_users << @pitches.map(&:members).flatten.uniq
          @pitch_users << @pitches.map(&:collaboraters).flatten.uniq
          @pitch_users << @pitches.map(&:user_id)
          not_required = users & (@pitch_users.flatten.uniq.map(&:to_s))
          users = users - not_required
        end
      end
      if params[:targetting][:last_activity].present? && params[:targetting][:last_activity] != "0"
        time = params[:targetting][:last_activity] == "1" ? "" : ( params[:targetting][:last_activity] == "2" ? 2.day : (params[:targetting][:last_activity] == "3" ? 7.day : (params[:targetting][:last_activity] == "4" ? 14.day: 1.month)))
        if time.present?
          users = CommunityFeed.where(:created_at => (Time.now - time)..Time.now).in(:created_by => users).map(&:created_by).map(&:id).uniq.map(&:to_s)
        end
      end
      if params[:targetting][:role] == "participant" and params[:targetting][:applicant_filter_code].present?
        filtered_users = User.in("custom_fields.#{params[:targetting][:applicant_filter_code]}" => params[:targetting][:applicant_filter_option]).map(&:id).map(&:to_s)
        users = users & filtered_users
      end

      if params[:targetting][:joined_team_filter].present?
        new_users = []
        pitches = context_program.pitches
        if params[:targetting][:role] == "participant"
          joined_members = pitches.map(&:joined_team_members)
          joined_members.map{|hash| hash.map{|k, v| new_users<< k if (v > (Time.now - params[:targetting][:joined_team_filter].to_i.week) and hash.present?)}}
        elsif params[:targetting][:role] == "mentor"
          joined_mentors = pitches.map(&:joined_team_mentors)
          joined_mentors.map{|hash| hash.map{|k, v| new_users<< k if (v > (Time.now - params[:targetting][:joined_team_filter].to_i.week) and hash.present?)}}
        end
        users = users & new_users.map(&:to_s)
      end

      @users = User.in(:id => users)

    else
      @type = "pitch"
      pitches = context_program.pitches.map(&:id)
      if params[:targetting][:project_phase_achived].present?
        pitches_phase_achived = context_program.workflows.where(:code => params[:targetting][:project_phase_achived]).present? ? context_program.workflows.where(:code => params[:targetting][:project_phase_achived]).first.pitch_phases.map(&:pitch_id).uniq : nil
        if pitches_phase_achived.present?
          pitches = pitches & pitches_phase_achived
        else
          pitches = []
        end
      end
      if params[:targetting][:project_phase_not_achived].present?
        pitches_phase_not_achived = context_program.workflows.where(:code => params[:targetting][:project_phase_not_achived]).present? ? context_program.workflows.where(:code => params[:targetting][:project_phase_not_achived]).first.pitch_phases.in(pitch_id: context_program.pitches.map(&:id)).map(&:pitch) : nil
        if pitches_phase_not_achived.present?
          pitches = pitches - pitches_phase_not_achived
        end
      end
      if params[:targetting][:last_activity].present? && params[:targetting][:last_activity] != "0"
        time = params[:targetting][:last_activity] == "1" ? "" : ( params[:targetting][:last_activity] == "2" ? 2.day : (params[:targetting][:last_activity] == "3" ? 7.day : (params[:targetting][:last_activity] == "4" ? 14.day: 1.month)))
        if time.present?
          pitches = CommunityFeed.where(:created_at => (Time.now - time)..Time.now).in(:pitch_id => pitches).map(&:pitch_id).uniq
        end
      end
      if params[:targetting][:pitch_filter_code].present?
        filtered_pitches = Pitch.in("custom_fields.#{params[:targetting][:pitch_filter_code]}" => params[:targetting][:pitch_filter_option]).map(&:id)
        pitches = pitches & filtered_pitches
      end
      @pitches = Pitch.in(:id => pitches)
    end
  end

  def export_target
    @targetting = Targetting.where(id: params[:target_id]).first
    unless @targetting.role == "pitch"
      begin
      users = Targetting.find_users(@targetting.id, context_program.id)
      csv_string = Targetting.to_csv(users)
      send_data csv_string,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@targetting.name}.csv"
      rescue Exception => e
        flash[:notice] = "#{e.message}"
        redirect_to :back and return
      end
    else
      begin
      pitches = context_program.pitches.map(&:id)
      if @targetting.project_phase_achived.present?
        pitches_phase_achived = context_program.workflows.where(:code => @targetting.project_phase_achived).present? ? context_program.workflows.where(:code => @targetting.project_phase_achived).first.pitch_phases.map(&:pitch_id).uniq : nil
        if pitches_phase_achived.present?
          pitches = pitches & pitches_phase_achived
        else
          pitches = []
        end
      end
      if @targetting.project_phase_not_achived.present?
        pitches_phase_not_achived = context_program.workflows.where(:code => @targetting.project_phase_not_achived).present? ? context_program.workflows.where(:code => @targetting.project_phase_not_achived).first.pitch_phases.map(&:pitch).uniq : nil
        if pitches_phase_not_achived.present?
          pitches = pitches - pitches_phase_not_achived
        end
      end
      if @targetting.last_activity.present? and @targetting.last_activity != 0
        time = @targetting.last_activity == 1 ? "" : ( @targetting.last_activity == 2 ? 2.day : (@targetting.last_activity == 3 ? 7.day : (@targetting.last_activity == 4 ? 14.day: 1.month)))
        if time.present?
          pitches = CommunityFeed.where(:created_at => (Time.now - time)..Time.now).in(:pitch_id => pitches).map(&:pitch_id).uniq
        end
      end
      if @targetting.pitch_filter_code.present?
        filtered_pitches = Pitch.in("custom_fields.#{@targetting.pitch_filter_code}" => @targetting.pitch_filter_option).map(&:id)
        pitches = pitches & filtered_pitches
      end
      csv_string = Targetting.pitch_to_csv(pitches)
      send_data csv_string,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@targetting.name}.csv"
      rescue Exception => e
        flash[:notice] = "#{e.message}"
        redirect_to :back and return
      end
    end
  end

  def messaging
    @program= context_program
  end
end