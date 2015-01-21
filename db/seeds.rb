# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
ProgramType.create!(:title => "Incubator", :no_program => true, 
  :all_applicants_accepted => true, :some_applicants_accepted => true)

ProgramType.create!(:title => "Accelerator + Application Filtering", 
  :no_program => false, :all_applicants_accepted => false, 
  :some_applicants_accepted => true)

ProgramType.create!(:title => "Accelerator phase only", 
  :no_program => false, :all_applicants_accepted => true, 
  :some_applicants_accepted => false)

ProgramType.create!(:title => "Competition/Challange", 
  :no_program => true, :all_applicants_accepted => false, 
  :some_applicants_accepted => false)

ProgramType.create!(:title => "Mentoring Program", 
  :no_program => false, :all_applicants_accepted => true, 
  :some_applicants_accepted => true)

ProgramType.create!(:title => "Collaborative Innovation Program", 
  :no_program => false, :all_applicants_accepted => true, 
  :some_applicants_accepted => true)

RoleType.seeds!

defined?(Semantic) && Semantic.create_defaults!