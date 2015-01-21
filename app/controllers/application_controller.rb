class ApplicationController < ActionController::Base
  #Authorization
  include App::Rolefy::Kontrollers
  include ApplicationHelper
  include SimpleCaptcha::ControllerHelpers

  protect_from_forgery
  before_filter :domain_mapping
  before_filter :authenticate_user!, :set_context_program#, :ensure_paid
  force_ssl if: :ssl_required?
  #for handling unauthorization exception
  rescue_from App::Rolefy::NotAuthorized do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def domain_mapping
    if !DomainMap.blank?
      if !mapped_url(request.host).blank?
        if !mapped_url(request.host).program_id.blank?
          #code for program landing page
          program_id = mapped_url(request.host).program_id
          if request.url==root_url && !current_user
            redirect_to program_path(program_id)
          end
        end
        if !mapped_url(request.host).organisation_id.blank?
          #code for organisation landing page
          organisation_id = mapped_url(request.host).organisation_id
          if request.url==root_url && !current_user
            redirect_to organisation_path(organisation_id)
          end
        end
      end
    end
  end

  #TODO: Needs to be made flexible
  def current_organisation
    if user_signed_in?
      return context_program.organisation if !!context_program
      Organisation.for(current_user).first || 
        (current_user["_company_admin"] && Organisation.find(current_user["_company_admin"]).first)
    end
  end
  helper_method :current_organisation

  #TODO: needs to be integrated with Role System
  def visible_programs
    @visible_programs = mapped_program
  end
  helper_method :visible_programs

  def context_program
    return @context_program if @context_program && 
      @context_program.id.to_s == session[:context_program]
    @context_program = Program.find(session[:context_program]) rescue nil
  end
  helper_method :context_program

  def need?(roles, on)
    return false if current_user.blank? #!defined? current_user || !current_user
    authorized = roles.collect{|r| current_user.send("#{r}?", on) }
    authorized.any?
  end
  helper_method :need?

  def ensure_paid
    if current_user && current_organisation && 
      !current_organisation.owner?(current_user.id)
      unless Payment.paid?(current_organisation, current_user)
        redirect_to subscriptions_payments_path if context_program.try(:is_paid) and !context_program.try(:is_manualy_paid)
      end unless need?(["company_admin"], current_organisation )
    end
  end

  def roles_string
    return @role_string if @role_string.present?
    roles = current_user.role_code_for(context_program, 
      current_organisation)
    @role_string = ["all", roles].flatten.compact
  end
  helper_method :roles_string

  def set_context_program
    if user_signed_in?
      begin
        guess_it = params[:program_id] || params[:id]
        @context_program = Program.find(guess_it)
        session[:context_program] = @context_program.id.to_s
      rescue
        if !!session[:context_program]
          begin
            @context_program = Program.find(session[:context_program])
          rescue
            current_user.visible_programs.first
            session[:context_program] = !!@context_program ? @context_program.id.to_s : nil
          end
        else
          @context_program = current_user.visible_programs.first
          session[:context_program] = !!@context_program ? @context_program.id.to_s : nil
        end
      end
    else
      guess_it = params[:program_id] || params[:id]
      @context_program = Program.find(guess_it) rescue nil
      session[:context_program] = !!@context_program ? @context_program.id.to_s : nil
    end
  end

  #TODO: only use for debugging. remove in production environment
  def debug(message = nil)
    if Rails.env.development? || Rails.env.test?
      logger.info("\t\t[DEBUG][FROM #{self.class}][STARTS]")
      logger.info("\t\t[DEBUG][DUMP PARAMS] #{params.inspect}")
      logger.info("\t\t[DEBUG] #{message}")
      logger.info("\t\t[DEBUG][FROM #{self.class}][ENDS]") 
    end
  end
  alias_method :d, :debug

  def after_sign_out_path_for(resource_or_scope)
    field = (current_user ? ((current_user.try(:attributes).try(:keys) & ["_awaiting_participant", "_awaiting_mentor"]).first) : nil)
    if !params[:organisation_id].blank? && params[:level] == "eco" 
      organisation_path(params[:organisation_id])
    elsif context_program
      program_path(context_program)
    elsif field
      program = Program.where(id: current_user.try(field).try(:first)).first
      program ? program_path(program) : root_path
    else
      root_path
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    session[:first_time_in] = true
    if !params[:organisation_id].blank? && params[:level] == "eco"
      organisation_path(current_organisation)
    elsif !session[:user_return_to].blank?
      session[:user_return_to]
    elsif !context_program.blank? && !context_program.course_setting.blank?
      course_setting_path(context_program.course_setting.user_section)
    else
      super
    end
  end

  private 
  def course_setting_path(user_section)
    if context_program.try(:courses_part_of_program)
      if (user_section == "course_show")
        if !context_program.pitches.blank? && !context_program.course.blank?
          polymorphic_path([context_program, context_program.pitches.first, context_program.course, :show])
        else
          root_path
        end
      elsif user_section == "my_work_community"
        root_path
      elsif user_section == "my_work_project"
        if need?(["participant"], context_program)
          pitch_count = context_program.pitches.where(user_id: current_user.id.to_s).count
          pitch_count == 0 ? new_program_pitch_path(context_program) : root_path
        else
          root_path
        end
      else
        user_section
      end
    else
      root_path
    end
  end

  def mapped_program
    visible_programs = current_user.visible_programs
    if !DomainMap.blank?
      if !mapped_url(request.host).blank?
        if !mapped_url(request.host).program_id.blank?
          program_id = mapped_url(request.host).program_id
          visible_programs = current_user.visible_programs.where(:id => program_id)
        end
      end
    end
    return visible_programs
  end

  def mapped_url(domain) 
    verified_domain = DomainMap.where(:verified => true)
    domains = [domain, domain.gsub(/^www\./,"")]
    domains.collect{|p| verified_domain.where(:domain => p) }.flatten.first
  end
  helper_method :mapped_url 

  def ssl_required?
     ((request.host == 'droicon.fr') or (request.host == "apptual.com") or (request.host == "opencalls.cde.catapult.org.uk"))
   end

end
