#!/usr/bin/ruby

require 'mysql2'
require_relative('../storycreator/targetfile.rb')

person = Targetfile.new('hyperlocal_montgomery_arrests_data.tsv')
person.get_headers

charges = Targetfile.new('hyperlocal_montgomery_arrests_data_charges.tsv')
charges.get_headers

client = Mysql2::Client.new(:host => "localhost", :username => "journatic", :password => "incorrecthorsebatterystaple")

client.query("use bedrock")

items = Hash.new
person.each do |arrest|
  items[arrest['name']] = charges.select{|line| line['record_id'] == arrest['id']}
  p "#{arrest['name']} => #{items[arrest['name']]}"
  wait = gets
end
