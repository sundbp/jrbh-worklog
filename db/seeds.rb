# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# change this path to where your dump is
data_dump_file = "/Users/patrik/Documents/Worklog/worklog_total.dump"
task_company_file = "/Users/patrik/Documents/Worklog/worklog_task_company.dump"

WorkPeriodStruct = Struct.new(:start,:end,:user,:task,:comment)

# various mappings 
alias_to_user = {
        "JH" => "jenharris",
        "JO" => "josbaldaston",
        "MS" => "msim",
        "PC" => "pcroney",
        "HL" => "hleivers"
        }

admins = ["JH", "JO"]

# create users
alias_to_user.each_pair do |key,value|
  admin = admins.include? key
  User.create(:login => value, :alias => key, :admin => admin)
  print "Created user '#{key}'\n"
end

task_to_company = nil
File.open(task_company_file) do |f|
  task_to_company = Marshal.load(f)
end

#create companies
task_to_company.values.uniq.sort.each do |c|
  Company.create(:name => c)
  print "Created company '#{c}'\n"
end

#create worklog tasks
task_to_company.each_pair do |task,company|
  c = Company.find_by_name(company)
  WorklogTask.create(:name => task, :company_id => c.id)
  print "Created worklog task '#{task}'\n"
end

data = nil
File.open(data_dump_file) do |f|
  data = Marshal.load(f)
end

i = 0
data.each do |x|
  u = User.find_by_alias(x.user)
  unless u
    User.create(:login => x.user+"login", :alias => x.user, :admin => false)
    u = User.find_by_alias(x.user)
  end

  t = WorklogTask.find_by_name(x.task)
  
  WorkPeriod.create(:user_id => u.id, :worklog_task_id => t.id, :start => x.start, :end => x.end, :comment => x.comment)
  i = i + 1
end
print "Creataed #{i} work periods.\n"