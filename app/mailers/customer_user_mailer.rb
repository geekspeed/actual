class CustomerUserMailer  < Devise::Mailer 
  helper :application # gives access to all helpers defined within `application_helper`.
    include AbstractController::Callbacks

    def confirmation_instructions(record, opts={})
      if !(defined? record.try(:_selector)[0]).blank?
        @program = Program.find(record._selector).first
      elsif !(defined? record.try(:_mentor)[0]).blank? 
        @program = Program.find(record._mentor).first 
      elsif !(defined? record.try(:_panellist)[0]).blank? 
        @program = Program.find(record._panellist).first 
      elsif !(defined? record.try(:_participant)[0]).blank?
        @program = Program.find(record._participant).first 
      elsif !(defined? record.try(:_awaiting_mentor)[0]).blank?
        @program = Program.find(record._awaiting_mentor).first
      elsif !(defined? record.try(:_awaiting_participant)[0]).blank?
        @program = Program.find(record._awaiting_participant).first
      elsif !(defined? record.try(:_ecosystem_member)[0]).blank?
        @organisation = Organisation.find(record._ecosystem_member).first
      end
      if !@program.blank?
        opts[:from] = "#{@program.title} <info@apptual.com>"
      end
      if !@organisation.blank?
        opts[:from] = "#{@organisation.company_name} <info@apptual.com>"
      end
      objekt = @program || @organisation
      @domain_host = DomainMapping.domain(objekt)
      super
    end
  # default from: Devise.mailer_sender
    def reset_password_instructions(record, opts={})
      if !(defined? record.try(:_selector)[0]).blank?
        @program = Program.find(record._selector).first
      elsif !(defined? record.try(:_mentor)[0]).blank? 
        @program = Program.find(record._mentor).first 
      elsif !(defined? record.try(:_panellist)[0]).blank? 
        @program = Program.find(record._panellist).first 
      elsif !(defined? record.try(:_participant)[0]).blank?
        @program = Program.find(record._participant).first 
      end 
      if !@program.blank?
        opts[:from] = "#{@program.title} <info@apptual.com>"
      end
      @domain_host = DomainMapping.domain(@program)
      super
    end
end
