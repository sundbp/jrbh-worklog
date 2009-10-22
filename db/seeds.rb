# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# change this path to where your dump is
dump_file = "/Users/patrik/Documents/Worklog/worklog_total.dump"

WorkPeriodStruct = Struct.new(:start,:end,:user,:task,:comment)

# various mappings 
alias_to_user = {
        "JH" => "jenharris",
        "JO" => "josbaldaston",
        "MS" => "msim",
        "PC" => "pcroney",
        "HL" => "hleivers"
        }

File.open(dump_file) do |f|
  data = Marshal.load(f)
end

