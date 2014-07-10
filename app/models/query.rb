class Query < ActiveRecord::Base
	attr_accessor :output
	require_relative '../assets/Loki/data_sanitation.rb'
	validates :method, presence: true
end
