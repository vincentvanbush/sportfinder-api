# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'Creating categories...'
titles = [
	'football',
	'basketball',
	'voleyball',
	# 'F1',
	'tennis',
	# 'chess',
	# 'curling',
	# 'snooker',
	# 'golf',
	# 'dart'
	'race']
disciplines = []
titles.each do |title|
	disciplines << Discipline.create(title: title)
end

puts 'Creating users...'
passwords = ['qweqweqwe', 'asdasdasd', 'zxczxczxc']
users = []
20.times do 
	pass = passwords.sample
	users << User.create(
		email: Faker::Internet.email,
		password: pass,
		password_confirmation: pass
	)
end

puts 'Creating messages...'
messages = []
300.times do 
	messages << Message.new(
		content: Faker::Lorem.sentences(2)
	)
end

puts 'Creating events...'
events = []

100.times do |i|
	discipline = disciplines.sample
	user = users.sample
 	contender_params = []
 	contender_params << { squad_members: [] }
	events << Event.create(
		title: Faker::Lorem.sentence(2, false, 2),
		description: Faker::Lorem.sentences(3),
		venue: Faker::Lorem.sentence(2, false, 0),
		start_date: Faker::Time.forward(14),
		user: user,
		discipline: discipline,
		messages: messages[i*3..i*3+2],
		contenders: contender_params
	)
end
