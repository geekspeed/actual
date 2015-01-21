class EcoSummariesController < ApplicationController
  
  before_filter :load_organisation

  def new
    @summary = @organisation.build_eco_summary
    @summary.eco_plans.build
    @summary.eco_partners.build
    @summary.eco_quotes.build
    @summary.build_eco_summary_customization
    @summary.build_eco_summary_order
    @summary.eco_free_forms.build
    @summary.eco_case_studies.build
  end

  def create
    @summary = @organisation.build_eco_summary(merge_tags)
    if @summary.save
      redirect_to :action => :edit
    else
      render :action => :new
    end
  end

  def edit
  	@summary = @organisation.eco_summary
    redirect_to :action => :new if @summary.blank?
  end

  def update
    @summary = @organisation.eco_summary
    if !@summary.eco_summary_customization.present?
      @summary.build_eco_summary_customization
    end
    if !@summary.eco_summary_order.present?
      @summary.build_eco_summary_order(:order => params[:eco_summary_eco_summary_order_attributes_order])
    end
    if @summary.update_attributes(merge_tags)
      create_eco_summary_semantics(params[:semantics])
      flash[:notice] = "Eco summary updated successfully."
      redirect_to :back
    else
      render :action => :edit
    end
  end

  def eco_partner_destroy
    @eco_partner = EcoPartner.find params[:eco_partner_id]
    if @eco_partner.destroy
      flash[:notice] = "Eco Partner Destroyed"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def eco_quote_destroy
    @eco_quote = EcoQuote.find params[:eco_quote_id]
    if @eco_quote.destroy
      flash[:notice] = "Eco Quote Destroyed"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def eco_case_study_destroy
    @eco_case_study = EcoCaseStudy.find params[:eco_case_study_id]
    if @eco_case_study.destroy
      flash[:notice] = "Case Study Destroyed"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def eco_free_form_destroy
    if !params[:eco_free_form_section_id].blank?
      @eco_free_form = EcoFreeForm.where(:section_id => params[:eco_free_form_section_id])
    else
      @eco_free_form = EcoFreeForm.find params[:eco_free_form_id]
    end    
    
    if @eco_free_form.destroy
      flash[:notice] = "Eco Free Form Destroyed"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def eco_plan_destroy
    @program_plan = EcoPlan.find params[:eco_plan_id]
    if @program_plan.destroy
      flash[:notice] = "Eco Plan Destroyed"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  private
  
  def load_organisation
    @organisation = Organisation.find(params[:organisation_id]) if params[:organisation_id].present?
  end

  def merge_tags
    params[:tags].present? ? params[:eco_summary].merge(params[:tags]) : 
      params[:eco_summary]
  end

  def create_eco_summary_semantics(semantics)
    semantics.each do |key, semantic|
      Semantic.for_organisation(@organisation.id).find_or_create_by(key: 
        key).update_attributes(semantic)
    end if semantics
  end

end
