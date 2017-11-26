require 'yaml'

FILENAME = 'borrachos.yaml'
@manifest = YAML.load_file FILENAME

def percent_of_win(name)
  raise "The player #{name} never played." unless get_players.include?(name)
  matches = 0
  win = 0
  percent = 0
  @manifest['borrachos']['matches'].each do |match|
    if play_the_game?(match['date'], name)
      winner = match['winner']
      match['teams'][winner]['players'].each do |p|
        #puts 'player is: ' + p + '| ' + name
        win += 1 if p.eql?(name)
      end
      matches += 1
    end
  end
  #puts 'maches: ' + matches.to_s
  #puts 'win: ' + win.to_s
  unless matches.eql?(0)
    percent = win*100/matches
  end
  percent
end

def play_the_game?(date, player)
  @manifest['borrachos']['matches'].each do |match|
    if match['date'].eql?(date)
      #puts match['teams']
      match['teams'].each do |team, players|
        return true if players['players'].include?(player)
      end
    end
  end
  false
end

def statics
  best_percentage = {'percent'=> '0', 'players'=> []}
  worst_percentage = {'percent'=> '100', 'players'=> []}
  get_players.each do |player|
    percent = percent_of_win(player)
    if best_percentage['percent'].to_i == percent
      best_percentage['players'].push(player)
    elsif best_percentage['percent'].to_i < percent
      best_percentage['percent'] = percent
      best_percentage['players'] = []
      best_percentage['players'].push(player)
    end
  end
  puts "The best percentage is #{best_percentage['percent']}% and the players are:"
  best_percentage['players'].each { |player| puts " - #{player}" }
  get_players.each do |player|
    percent = percent_of_win(player)
    if worst_percentage['percent'].to_i == percent
      worst_percentage['players'].push(player)
    elsif worst_percentage['percent'].to_i > percent
      worst_percentage['percent'] = percent
      worst_percentage['players'] = []
      worst_percentage['players'].push(player)
    end
  end
  puts "The worst percentage is #{worst_percentage['percent']}% and the players are:"
  worst_percentage['players'].each { |player| puts " - #{player}" }
end

def matches(details=false)
  if details
    puts '+-------+'
    @manifest['borrachos']['matches'].each do |match|
      puts "| #{match['date']} |"
    end
    puts '+-------+'
  end
  return @manifest['borrachos']['matches'].size
end

def matches_played(player)
  amount = 0
  @manifest['borrachos']['matches'].each do |match|
    amount += 1 if play_the_game?(match['date'], player)
  end
  amount
end

def active_players
  number_of_active = 0
  get_players.each do |player|
    number_of_active += 1 if matches_played(player) > 2
  end
  number_of_active
end

def show_all
  puts '+---------------+-------+---------+'
  puts '| player        | [%]   | matches |'
  puts '+---------------+-------+---------+'
  get_players.each do |player|
    puts "| #{player}   \t| #{percent_of_win(player)}\t| #{matches_played(player)} \t  |"
  end
  puts '+---------------+-------+---------+'
  puts "Matches: #{matches(true)}"
  puts "Total of players: #{get_players.size}"
  puts "Total of active players(more than 2 matches): #{active_players}"

end

def add_game
  puts 'Date:'
  date = STDIN.gets.chomp
  @manifest['borrachos']['matches'].push({'date'=> date, 'teams'=> {'a'=>{'players'=>[],'sets'=>0},'b'=>{'players'=>[],'sets'=>0}},'winner'=>0})
  puts 'Team A - '
  add_team('a')
  puts 'Team B - '
  add_team('b')
  puts 'Who won the game?'
  winner = STDIN.gets.chomp
  @manifest['borrachos']['matches'].last()['winner'] = winner
  save
end

def add_team(team)
  id = 0
  while id != '-1'
    list_id_players
    puts 'Add player?:'
    id = STDIN.gets.chomp
    case id
    when '-1'
       break
    when '0'
      new_player(team)
    else
      add_player(id, team)
    end
  end
  puts "How many sets team #{team} won?"
  sets = STDIN.gets.chomp
  @manifest['borrachos']['matches'].last()['teams'][team]['sets'] = sets
  save
end

def add_player(id, team)
  player = get_players[(id.to_i)-1]
  puts "Player is #{id} - #{player}"
  @manifest['borrachos']['matches'].last()['teams'][team]['players'].push(player)

end

def new_player(team)
  puts 'name::'
  name = STDIN.gets.chomp
  @manifest['borrachos']['players'].push(name)
  id = get_players.size
  puts "Player is #{id} - #{get_players[(id.to_i)-1]}"
  add_player(id, team)
end

def list_id_players
  i = 0
  puts "-1 - DONE"
  puts " 0 - add new player"
  while i < get_players.size
    puts " #{i+1} - #{get_players[i]}"
    i += 1
  end
end

def get_players
  @manifest['borrachos']['players']
end

def list_players
  puts '+---------------+'
  puts "| Players  \t|"
  puts '+---------------+'
  get_players.each do |player|
    puts "| #{player}   \t|"
  end
  puts '+---------------+'
end

def save
  File.open(FILENAME, "r+") do |file|
    file.write(@manifest.to_yaml)
  end
end

def main
  case ARGV[0]
  when 'add_game'
    STDOUT.puts 'adding game'
    add_game
  when 'show_all'
    statics
    show_all
  when 'list_players'
    list_players
  when 'personal_stats'
    name = ARGV[1]
    percent = percent_of_win(name)
    puts "Player #{name} won #{percent}%"
  else
    STDOUT.puts <<-EOF
  Please provide command name

  Usage:
    borracho show_all
    borracho add_game
    borracho personal_stats NAME
    borracho list_players
  EOF
  end
end

main
