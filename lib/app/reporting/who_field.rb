class WhoField
	def self.who_people_field_two(reporting,program,organisation)
		participants = User.participants(program.id.to_s)
    case reporting["who_field_2"] 
		when "all"
      WhatField.participants(reporting,program,participants)
    when "phase"
		when "participants_filter"
      if !reporting[:who_field_3].blank?
        custom_fields = reporting[:who_field_3]
        all_participants = []
        custom_fields.each do |option|
          option = option.split(".")
          custom_field_options =  {:"custom_fields.#{option[0]}" => option[1]}
          all_participants << participants.or(custom_field_options)
        end
        all_participant = all_participants.flatten.uniq.reject(&:blank?)
        WhatField.participants(reporting,program,all_participant)
      end
		when "project_filter"
		when "organisation_filter"
			case reporting["who_field_3"]
      when "organisation_type"   
        WhatField.participants(reporting,program,self.organisations_data(participants,:type,reporting))
      when "industry" 
        WhatField.participants(reporting,program,self.organisations_data(participants,:industry,reporting))
      when "size"
        WhatField.participants(reporting,program,self.organisations_data(participants,:size,reporting))
      end
  	end
  end

  def self.who_projects_field_two(reporting,program,organisation)
    projects = program.pitches
    case reporting["who_field_2"] 
    when "all"
      WhatField.projects(reporting,program,projects)
    when "phase"
      workflows = program.workflows.where(:code.in => reporting["who_field_3"])
      pitches = []
      workflows.each do |workflow|
        workflow.pitch_phases.each do |phase|
          pitches << phase.pitch
        end
      end
      all_project = pitches.flatten.uniq.reject(&:blank?)
      WhatField.projects(reporting,program,all_project)
    when "participants_filter"
    when "project_filter"
      if !reporting[:who_field_3].blank?
        custom_fields = reporting[:who_field_3]
        pitches = []
        custom_fields.each do |option|
          option = option.split(".")
          custom_field_options =  {:"custom_fields.#{option[0]}" => option[1]}
          pitches << program.pitches.or(custom_field_options)
        end
        all_project = pitches.flatten.uniq.reject(&:blank?)
        WhatField.projects(reporting,program,all_project)
      end
    when "organisation_filter"
      case reporting["who_field_3"]
      when "organisation_type"   
        WhatField.projects(reporting,program,self.organisations_data(projects,:type,reporting))
      when "industry" 
        WhatField.projects(reporting,program,self.organisations_data(projects,:industry,reporting))
      when "size"
        WhatField.projects(reporting,program,self.organisations_data(projects,:size,reporting))
      end
    end
  end

  def self.who_organisations_field_two(reporting,program,organisation)
    organisations = Organisation.where(:id.in => self.org_ids(organisation,program))
    case reporting["who_field_2"] 
    when "all"
      WhatField.organisations(reporting,program,organisations)
    when "organisation_type" 
      organisations = organisations.where(:type => reporting["who_field_3"])
      WhatField.organisations(reporting,program,organisations)  
    when "industry"   
      organisations = organisations.where(:industry => reporting["who_field_3"])
      WhatField.organisations(reporting,program,organisations)
    when "size"
      organisations = organisations.where(:size => reporting["who_field_3"])
      WhatField.organisations(reporting,program,organisations)
    end
  end

  private

  def self.org_ids(organisation,program)
    users = []
    organisation_ids = []
    RoleType.all.each do |rt|
      users << User.in("_#{rt.code}" => program.id.to_s)
    end
    users = users.flatten.uniq
    organisation_ids << users.collect{|p| p.organisation}.reject(&:blank?).flatten
    organisation_ids << program.pitches.collect(&:organisation).reject(&:blank?)
    organisation_ids << program.try(:organisation).try(:id).to_s
    organisation_ids << organisation.try(:owner).try(:organisation)
    organisation_ids = organisation_ids.flatten.uniq 
  end

  def self.organisations_data(query_model,org_attr,reporting)
    query_model.map{|p| (p if Organisation.where(:id => p.organisation).try(:first).try(org_attr) == reporting["who_field_4"] )}.reject(&:blank?)
  end
end