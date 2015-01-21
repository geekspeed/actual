require 'resque/server'
require 'resque_scheduler'
require 'subdomain'
Resque::Scheduler.dynamic = true
Apptual::Application.routes.draw do

  get "programs/:id/search" => "search#index", :as => :index_search

  devise_for :users, :controllers => {:registrations => 
    "registrations", :invitations => 'invitations', :omniauth_callbacks => "users/omniauth_callbacks",
     :passwords => "passwords", :confirmations => 'confirmations'
  } do
      get  "/users/invitation/accept" => "invitations#accept"
      get  "/users/invitation/check_email" => "invitations#check_email"
      get  "/users/invitation/find_user" => "invitations#find_user"
      get  "/users/invitation/invite_existing" => "invitations#invite_existing"
  end
  
  devise_scope :user do
    get "/users/sign_up/step_2/:id" => "registrations#step_2", 
      :as => :step_2_user_registration
    get "/users/force/:id" => "registrations#force_sign_in", :as => :force_sign_in
    put "users/update_without_session/:id" => "registrations#update_without_session",
      :as => :update_without_session_registration
    get "/users/about_me" => "registrations#about_me", :as => :about_me_registration
    put "/users/update_about_me" => "registrations#update_about_me", :as => :update_about_me_registration
    put "/users/accept_invitation" => "registrations#accept_invitation", :as => :invitation_validation
    get "/profile/:id" => "registrations#show", :as => :user

    post 'users/omniauth_callbacks/create_twitter_user' => "users/omniauth_callbacks#create_twitter_user"
    get "/users/finish" => "registrations#finish", :as => :finish_registration
    get "users/show_faq" => "registrations#show_faq"
    get "users/pages_visited" => "registrations#pages_visited"
    put "/users/social_update" => "registrations#social_update", :as => :social_update
    get "/users/edit_user" => "registrations#edit_user", :as => :edit_user
    put "users/admin_update/:id" => "registrations#admin_update", :as => :admin_update
  end
# constraints(Subdomain) do
    # match '/' => 'registrations#show'
  # end  
  resources :organisations do
    get "/members/:role_code" => "organisations#members", :on => :member,
      :as => :members
    get   :eco_login,      on: :member
    get   :buzz,      on: :member
    post  :buzz_post, on: :member
    get   :popup_details,      on: :member
    resources :community_feeds, :only => [:destroy] do
      put :like, :on => :member
      put :unlike, :on => :member
      put :feature, :on => :member
      put :unfeature, :on => :member
    end
    resource :summary, :controller => :eco_summaries
    get :faqs,      on: :member    
    put :faq_save,      on: :member
    put :faq_update,      on: :member
    delete :faq_destroy,      on: :member
    post :contact_us, :on => :member
    resources :coupons, :only => [:index, :show, :create, :new, :destroy]
    resources :subscriptions, :only => [:edit, :create, :new, :update, :delete] do
      get   :soft_deleted_user,   on: :collection
    end
    
    get   :reactivate_account,  on: :collection
    get   :deactivate_account,  on: :collection

    get :badge_authority_details
    post :badge_authority_details_save
    
  end

  resources :comments, :only => [:create, :destroy] do
    put :like, :on => :member
    put :unlike, :on => :member
    get :like_from_mail, :on => :member
  end

  resources :surveys do
    resources :questions
  end

  resources :payments do
    get :plans, on: :collection
    get :subscriptions, on: :collection
    get :check_vat, on: :collection
    get :refund, on: :collection    
  end

  resources :ecosystems, :only => [:index, :show, :create, :new, :destroy]

  resources :user_contact_requests, :only => [:create]


  resources :programs do
    get "manage_form"
    put "manage_form_save"
    put "feed_form"
    get "change_feed_form"
    get :dashboard
    get :export_users_detail
    get :export_projects_detail
    get :download_phase_in_csv, :on => :member
    get :get_action_list
    get :community_tab
    put :update_custom_filter
    get :get_rule
    put :update_rule
    delete :delete_rule
    collection do
      post :contact_us
    end

    resources :voting_sheets, :only => :none do
      post :download,:on=>:collection
    end

    resources :messages, :only => :none do
      put :participants, :on => :collection
      put :pitches, :on => :collection
      put :mentor_pitches, :on => :collection
      put :phase_messages, :on => :collection
      put :msg_pitch_team, :on => :collection
      get :customize_email_messages, :on => :collection
      get :feedback_emails,:on=>:collection
      post :feedback_emails_save,:on=>:collection
      get :admin_invite ,:on=>:collection
      post :admin_invite_save ,:on => :collection
      get :team_member_invite ,:on=>:collection
      post :team_member_invite_save ,:on => :collection
      get :team_mentor_invite ,:on=>:collection
      post :team_mentor_invite_save ,:on => :collection
      get :comment_emails,:on=>:collection
      post :comment_emails_save,:on=>:collection
      get :mentor_offer_invite,:on=>:collection
      post :mentor_offer_invite_save,:on=>:collection
      get :join_team,:on=>:collection
      post :join_team_save,:on=>:collection
      get :submit_pitch,:on=>:collection
      post :submit_pitch_save,:on=>:collection
      get :collaboration_successfull,:on=>:collection
      post :collaboration_successfull_save,:on=>:collection
      get :download_csv,:on=>:collection
      get :join_team_email,:on=>:collection
      post :join_team_email_save,:on=>:collection
      get :declines_join_team_request,:on=>:collection
      post :declines_join_team_request_save,:on=>:collection
      get :rate_events_mail,:on=>:collection
      post :rate_events_mail_save,:on=>:collection
    end

    resources :customisations, :only => [:new, :create] do
      delete :delete_custom_fields, :on => :collection
      put :remove_basic_fields, on: :collection
    end

    resources :faqs, :only => [:new, :create, :show, :update, :destroy]
    resources :settings, :only => [:new, :create] do
      post :cloneable, on: :collection
    end

    resources :workflows, :only => [:index, :create] do
      put :toggle_status, on: :member
      put :achieved, on: :member
      put :undo, on: :member
      delete :delete_milestone, on: :member
    end

    resources :events do
      get :accept, :on => :member
      post :reject_participant, :on => :collection
      get :manage_participant, :on => :member
      get :confirm_participant, :on => :collection
      resources :event_sessions, :only => [:destroy] do
        get :export_event_session, :on => :member
        get :print_event_session, :on => :member
        post :message_all, :on => :collection
      end
    end

    resources :community_feeds, :only => [:index, :create, :destroy, :show] do
      put :like, :on => :member
      put :unlike, :on => :member
      put :feature, :on => :member
      put :unfeature, :on => :member
      put :non_sticky, :on => :member
      put :sticky, :on => :member
      put :remove_from_blog, :on => :member
      put :add_to_blog, :on => :member
      put :remove_from_eco_blog, :on => :member
      put :add_to_eco_blog, :on => :member
      get :like_from_mail, :on => :member
    end
    resource :summary, :controller => :program_summaries do
      get :authorize_eventbrite_account, :on => :member
      get :create_eventbrite_account, :on => :member
      put :add_eventbrite_user_key, :on => :member
      get :fetch_eventbrite_events, :on => :member
      post :create_eventbrite_events, :on => :member
      put :generate_nav_links, :on => :collection
    end
    resource :program_plans do
      get :attending, :on => :member
      get :not_attending, :on => :member
      get :attendees, :on => :member
    end
    resource :scope, :controller => :program_scopes
    resource :invitation, :controller => :program_invitations do
      get :invites, :on => :collection
      post :send_invites, :on => :collection
    end
    
    resource :due_diligence do
      get :judging_score, :on => :collection
      get :export_judging_details, :on => :collection
    end
    
    resources :phases, :only => :index do
      put :task_manager, :on => :collection
      post :task_manager, :on => :collection
      post :remind, :on => :collection
      post :message_all, :on => :collection
      get :manage, :on => :collection
      put :transition, :on => :collection
    end
    resources :pitches do
      post :iteration, :on => :member
      get :feeds, :on => :member
      get :team, :on => :member
      get :nudge, :on => :member
      get :be_mentor, :on => :member
      put :be_member, :on => :member
      get :join_team, :on => :member
      put :join_team, :on => :member
      put :invite_mentor, :on => :member
      get :contacts, :on => :member
      put :add_mentor, :on => :member
      put :remove_mentor, :on => :member
      put :add_membership_requester, :on => :member
      put :remove_membership_requester, :on => :member
      put :add_collaborater_requester, :on => :member
      put :remove_collaborater_requester, :on => :member
      put :shortlist, :on => :member
      put :finalist, :on => :member
      put :skills_needed, :on => :member
      post :due_diligence, :on => :member
      get :recommended_events, :on => :member
      put :assign_mentor, :on => :member
      delete :gallery_pic_remove, :on => :member
      
      resources :edit_pitch_field, :only => :none do
        get :toggle_edit_status, :on => :collection
      end
      
      resources :pitch_privacies, :only => [] do
        get :change_privacy_of_pitch, :on => :collection
      end
      
      resources :pitch_work_flow, :only => [] do
        get :check_required_fields, :on => :collection
      end
      
      get '/courses/:course_id/show' => "courses#show", as: :course_show
      post :refer_pitch_some_one, :on => :member
      post :be_collaborater, :on => :member
      resources :documents, :only => [:index, :create, :destroy] do
        put :approve, :on => :member
      end
      resources :feedbacks, :only => [:index, :create, :destroy]
      resources :milestones, :only => [:index, :create, :show] do
        get :achieved, :on => :member
        get :filter_tasks, on: :collection
        get :filter_tasks_by_date, on: :collection
        get :download_action_plan, on: :collection
        post :save_to_document, on: :collection
        get :filter_by_order, on: :collection
      end
      resources :tasks, :only => [:create, :destroy] do
        get :complete, :on => :member
      end
      resources :pitch_custom_feedbacks
      resource :pitch_custom_iterations
      resources :pitch_invitations do
        get :accept_invitation, :on => :member
        get :decline_invitation, :on => :member
      end
      resources :community_feeds, :only => [:show]
    end

    resource :user_adoption, only: [:edit, :update]
    resource :pitch_branches do
      collection do
        get :branch_fields
        get :custom_branch_fields
        get :user_custom_branch_fields
      end
    end
    member do
      get :program_login
      get :awaiting_users
      get :approve_user
      get :decline_user
      get :delete_user
    end
  
    resources :help_contents do
      collection do
        get :show_help_content
        get :add_custom_help
        get :add_custom_ques
        get :show_help_ques
      end
    end

    resources :courses, :only => [:index, :create] do
      get '/course_preview' => "courses#course_preview", as: :course_preview      
      get '/course_overview' => "courses#course_overview", as: :course_overview
      get '/new_module' => "courses#new_module", as: :new_module
      post '/module' => "courses#create_module", as: :create_module
      get '/module/:module_id/delete' => "courses#delete_module", as: :course_module_delete_module
      get '/module/:module_id/edit' => "courses#edit_module", as: :course_module_edit_module
      get '/module/:module_id/module_detail' => "courses#module_detail", as: :course_module_module_detail
      put '/module/:module_id/update' => "courses#update_module", as: :course_module_update_module
      get '/module/:module_id/new_activity' => "courses#new_activity", as: :course_module_new_activity
      post '/module/:module_id/add_activity' => "courses#add_activity", as: :course_module_add_activity
      get '/module/:module_id/play_module' => "courses#play_module", as: :course_module_play_module
      get '/module/:module_id/activity/:activity_id/edit_activity' => "courses#edit_activity", as: :course_module_module_activity_edit_activity
      put '/module/:module_id/activity/:activity_id/update_activity' => "courses#update_activity", as: :course_module_module_activity_update_activity
      get '/module/:module_id/activity/:activity_id/show_activity' => "courses#show_activity", as: :course_module_module_activity_show_activity
      get '/module/:module_id/activity/:activity_id/show_activity_material' => "courses#show_activity_material", as: :course_module_module_activity_show_activity_material
      post '/activity/:activity_id/activity_perform' => "courses#activity_perform", as: :module_activity_activity_perform
      delete '/module/:module_id/activity/:activity_id/delete_activity' => "courses#delete_activity", as: :course_module_module_activity_delete_activity
      delete '/delete_study_material/:study_material_id' => "courses#delete_study_material", as: :study_material_delete_study_material
      get '/module/:module_id/activity/:activity_id/study_materials' => "courses#study_materials", as: :course_module_module_activity_study_materials
      get '/module/:module_id/activity/:activity_id/show_exercise' => "courses#show_exercise", as: :course_module_module_activity_show_exercise
      get '/module/:module_id/activity/:activity_id/start_activity' => "courses#start_activity", as: :course_module_module_activity_start_activity
      get '/module/:module_id/activity/:activity_id/activity_video_watch' => "courses#activity_video_watch", as: :course_module_module_activity_activity_video_watch    
      put '/activity_performance/:id/activity_notes' => "courses#activity_notes", as: :activity_performance_activity_notes
      put '/activity_performance/:id/update_activity_notes' => "courses#update_activity_notes", as: :activity_performance_update_activity_notes
      delete '/activity_performance/:id/delete_activity_notes' => "courses#delete_activity_notes", as: :activity_performance_delete_activity_notes
      post '/module/:module_id/sort_activity' => "courses#sort_activity", as: :course_module_sort_activity
      put '/task_reference_links' => "courses#task_reference_links", as: :task_reference_links
    end
    resources :surveys do
      get :answers, :on => :member
      put :update_answers, :on => :member
      put :message_users, :on => :member
      resources :questions
      resources :reports
     end

    post '/courses/general_controls' => "courses#general_controls", as: :general_controls
  
    resources :reportings, :controller => :program_reportings do
      collection do
        get :index
        get :new_pie_chart
        get :new_line_chart
        post :new_pie_chart
        post :new_line_chart
        get :filter_custom_field
        get :phase_fields
        get :saved_graphs
        post :save_graph
        post :add_to_dashboard
        get :export_csv
        get :export_csv_build
        put :remove_from_dashboard
        put :added_to_dashboard
        delete :remove_report
        get :show_chart
        get :report_branding
      end
    end 

    resources :workspace
    resources :program_report_brandings
    resources :dynamic_mail_scheduling
    resources :visited_notifications
    resources :custom_events do
      post :log_admin_session, :on => :collection
      get :get_event_sessions, :on => :collection
      get :get_event_record_users, :on => :collection
      get :get_event_sessions_for_badge, :on => :collection
    end
    resources :custom_reminders
    resources :custom_reports do
      get :preview, on: :member
      delete :delete_custom_element, on: :member
      get :send_report, on: :member
      post :report_pdf, on: :collection
    end

    get :manage_badges, on: :member
    get :issued_badges, on: :member
    get :revoke_user_badge, on: :member
    resources :badges do
      get :show_badge, on: :member
      get :user_badge, on: :member
      post :issue_manual_badge, on: :member
    end

  end

  resource :dashboard do
    member do
      get 'main'
      get 'people'
      get 'filter_mentor'
      get 'my_work'
      get 'shortlisted_pitches'
      get 'recommended_pitches'
      get 'recommended_mentors'
      get 'organisations'
      get 'pitch_score_filter'
      get 'assign_pitch_mentor'
    end
    get :account_info, :on => :collection
    delete :delete_account, :on => :collection
    post :report_bug, on: :collection
    post :ask_questions, on: :collection
    delete :destroy_user, :on => :collection
  end
  
  resources :event_lists, :only => [:index]
  root :to => "dashboards#main"

  namespace :admin do
    resources :organisations, :only => [:index] do
      put :toggle, :on => :member
      get :setup, :on => :collection
      get :customize_email, :on => :collection
      get :role_invitation, :on => :collection
      post :role_invitation_save, :on => :collection
    end
    namespace :organisations do
      resources :customize_email do
        get :feedback_emails, :on => :collection
        get :comment_emails, :on => :collection
        get :admin_invite, :on => :collection
        get :team_member_invite, :on => :collection
        get :mentor_offer_invite, :on => :collection
        get :join_team, :on => :collection
        get :submit_pitch, :on => :collection
        get :team_mentor_invite, :on => :collection
        post :feedback_emails_save, :on => :collection
        post :comment_emails_save, :on => :collection
        post :admin_invite_save, :on => :collection
        post :team_member_invite_save, :on => :collection
        post :team_mentor_invite_save, :on => :collection
        post :mentor_offer_invite_save, :on => :collection
        post :join_team_save, :on => :collection
        post :submit_pitch_save, :on => :collection
      end
    end
  end

  resource :targettings do
    get :export_target
    get :messaging, :on => :collection
  end

  match "/targettings/preview" => "targettings#preview", via: [:get, :post]
  match 'programs/:id/promotion' => 'programs#promotion'

  match 'program_summaries/partner_destroy' => 'program_summaries#partner_destroy'

  match 'program_summaries/quote_destroy' => 'program_summaries#quote_destroy'

  match 'program_summaries/free_form_destroy' => 'program_summaries#free_form_destroy'
  
  match 'program_summaries/case_study_destroy' => 'program_summaries#case_study_destroy'

  resource :tokens do
    get :user_feedback
  end

  resource :event_ratings

  resources :badge_descs do
    get :show_desc
  end

  resources :domain_maps do
    member do
      get 'validate'
    end
  end

  match 'organisations/add_new' => 'organisations#add_new'
  put 'organisations/edit_user_org/:id' => 'organisations#edit_user_org', as: :organisations_edit_user_org
  put 'organisations/update_user_org/:id' => 'organisations#update_user_org', as: :organisations_update_user_org
  match 'organisation/autosuggest' => 'organisations#autosuggest'

  Resque::Server.use(Rack::Auth::Basic) do |user, password|  
    user == "developer" && password == "@558u@!"  
  end 
  mount Resque::Server.new, :at => "/jobs"

  delete 'eco_summaries/eco_partner_destroy'
  delete 'eco_summaries/eco_partner_destroy'
  delete 'eco_summaries/eco_quote_destroy'
  delete 'eco_summaries/eco_free_form_destroy'
  delete 'eco_summaries/eco_case_study_destroy'  
  delete 'eco_summaries/eco_plan_destroy'

  apipie
  namespace :api do 
    resources :user_badges do
      get "badge", on: :collection
      get "issuer_detail", on: :collection 
      get "assertion", on: :collection
    end
  end

  apipie
  namespace :api do 
    resources :user_badges do
      get "badge", on: :collection
      get "issuer_detail", on: :collection 
      get "assertion", on: :collection
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
   # match ':controller(/:action(/:id))(.:format)'
end
