require 'app/monkey_patch/date'
require 'app/monkey_patch/time'
Date.send(:include, MonkeyPatch::Date)
Time.send(:include, MonkeyPatch::Time)

require 'app/rolefy/documents'
require 'app/rolefy/kontrollers'
require 'app/rolefy/exceptions'

require 'app/custom_fields/models'
require 'app/custom_fields/base'
require 'app/custom_fields/upload_file'
Mongoid::Document.send(:include, App::CustomFields::Base)
require 'app/background/invitation_mailer'
require 'app/workflows/pitch_hook'
require 'app/background/solr_indexing'
#cloner
require 'app/cloner/base'
require 'app/reporting/program_reporting'
require 'app/reporting/who_field'
require 'app/reporting/what_field'
require 'app/reporting/how_field'

