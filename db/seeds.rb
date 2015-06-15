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
	'volleyball',
	'tennis',
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

football_contenders = [	'Arsenal', 'Manchester United', 'Manchester City', 'Chelsea', 'Liverpool',
						'Everton', 'Tottenham', 'Newcastle', 'Aston Villa', 'Swansea', 'West Ham',
						'Real Madrid', 'Barcelona', 'Atletico Madrid', 'Sevilla', 'Valencia',
						'PSG', 'Olympique Marsylia', 'Olympique Lyon', 'Bayern Monachium', 'Borrusia Dortmund']
basketball_contenders = ['Boston Celtics', 'Brooklyn Nets', 'New York Knicks', 'Philadelphis 76ers', 'Toronto Raptors',
						'Chicago Bulls', 'Cleveland Cavaliers', 'Detroit Pistons', 'Indiana Pacers', 'Milwaukee Bucks',
						'Atlanta Hawks', 'Charlotte Hornets', 'Miami Heat', 'Orlando Magic', 'Washington Wizards',
						'Dallas Maverics', 'Houston Rockets', 'Memphis Grizzlies', 'New Orleans Pelicans', 'San Antonio Spurs',
						'Denver Nuggets', 'Minnesota Timberwolves', 'Oklahoma City Thunder', 'Portland Trail Blazers', 'Utah Jazz',
						'Golden State Warriors', 'Los Angeles Clippers', 'Los Angeles Lakers', 'Phoenix Suns', 'Sacramento Kings']
tennis_contenders = ['Novak Djokovic', 'Roger Federer', 'Andy Murray', 'Stanislas Wawrinka' , 'Kei Nishikori',
					'Tomas Berdych', 'David Ferrer', 'Milos Raonic', 'Marin Cilic', 'Rafael Nadal',
					'Grigor Dimitrov', 'Jo-Wilfried Tsonga' ,'Gilles Simon', 'Feliciano Lopez', 'David Goffin']
volleyball_contenders = ['Asseco Resovia Rzeszów' ,'AZS Częstochowa', 'AZS Politechnika Warszawska', 'BBTS Bielsko-Biała', 'Cerrad Czarni Radom',
						'Cuprum Lubin', 'Effector Kielce', 'Indykpol AZS Olsztyn', 'JASTRZĘBSKI WĘGIEL', 'LOTOS Trefl Gdańsk',
						'MKS BANIMEX BĘDZIN', 'PGE Skra Bełchatów', 'Transfer Bydgoszcz', 'ZAKSA Kędzierzyn-Koźle']
race_contenders = ['Mercedes', 'Ferrari', 'Williams', 'Red Bull Racing', 'Lotus',
					'Sauber', 'Force India', 'Toro Rosso', 'McLaren', 'Marussia']

puts 'Creating events'
100.times do |i|
	discipline = disciplines.sample
	user = users.sample

 	contender_params = []
	if discipline.title == 'football'
		2.times do
			squad = []
			11.times do
				squad << Faker::Name.name
			end
			contender_params << { title: football_contenders.sample, squad_members: squad }		
		end
	elsif discipline.title == 'basketball'
		2.times do
			squad = []
			5.times do
				squad << Faker::Name.name
			end
			contender_params << { title: basketball_contenders.sample, squad_members: squad }
		end
	elsif discipline.title == 'volleyball'
		2.times do
			squad = []
			6.times do
				squad << Faker::Name.name
			end
			contender_params << { title: volleyball_contenders.sample, squad_members: squad }
		end
	elsif discipline.title == 'tennis'
		2.times do
			contender_params << { title: tennis_contenders.sample }
		end
	elsif discipline.title == 'race'
		contenders = race_contenders.shuffle[0..4]
		5.times do |i|
			contender_params << { title: contenders[i] }
		end
	else
 		contender_params << { squad_members: [] }
 	end
 	if i % 2 == 0
 		fin = false
 	else
 		fin = true
 	end
	event = Event.new(
		title: Faker::Lorem.sentence(2, false, 2),
		description: Faker::Lorem.sentence,
		venue: Faker::Lorem.sentence(2, false, 0),
		start_date: Faker::Time.forward(14),
		user: user,
		discipline: discipline,
		finished?: fin,
		messages: messages[i*3..i*3+2],
		contenders: contender_params
	)
	comments = []
	comments << Comment.new(
		content: Faker::Lorem.sentence,
		user: users.sample,
		event: event
	)
	event.comments = comments
	event.save
end
