class Query < ActiveRecord::Base
	attr_accessor :output
	validates :method, presence: true
end
