require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def calculate_total(cards)
    values = cards.map { |card| card.last }
    total = 0
    values.each do |value|
      if value == 'A'
        total += 11
      elsif value.to_i == 0
        total += 10
      else
        total += value.to_i
      end
    end

    values.select { |value| value == 'A' }.count.times do |value|
      total -= 10 if total > 21
    end

    total
  end 
end

get '/' do
  session.clear
  redirect '/set_name'
end

get '/set_name' do
  erb :set_name
end

post '/set_name' do
  session[:username] = params[:username]
  session[:player_money] = 500
  redirect '/bet'
end

get '/bet' do
  erb :bet
end

post '/set_bet' do
  session[:current_bet] = params[:current_bet]
  if session[:current_bet].to_i > session[:player_money]
    @error = "Whoops! You bet more than you have. Stay within your limit!"
    erb :bet
  else
    redirect '/game'
  end
end

get '/game' do
  if !session[:deck]
    suits = ['H', 'D', 'C', 'S']
    values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
    session[:deck] = suits.product(values)
    session[:deck].shuffle!
    session[:player_cards] = []
    session[:dealer_cards] = []
    session[:player_cards] << session[:deck].pop
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
  end
  erb :game
end

post '/player' do
  if params.keys.include?('hit')
    redirect '/hit_player'
  else
    session[:player_turn_over] = true
    redirect '/dealer'
  end
end

get '/hit_player' do
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) > 21
    @error = "#{session[:username]} went bust! #{session[:username]} lost!"
    session[:player_money] -= session[:current_bet].to_i
    session[:player_turn_over] = true
    session[:game_over] = true
  end
  erb :game
end

get '/dealer' do
  if calculate_total(session[:dealer_cards]) >= 17
    session[:dealer_turn_over] = true
    redirect '/compare_hands'
  else
    erb :game
  end
end

post '/hit_dealer' do
  session[:dealer_cards] << session[:deck].pop
  if calculate_total(session[:dealer_cards]) > 21
    @error = "Dealer went bust! #{session[:username]} won!"
    session[:player_money] += session[:current_bet].to_i
    session[:game_over] = true
  else
    redirect '/compare_hands'
  end
  erb :game
end

get '/compare_hands' do
  if calculate_total(session[:player_cards]) == calculate_total(session[:dealer_cards])
    @error = "It's a tie"
  elsif calculate_total(session[:player_cards]) > calculate_total(session[:dealer_cards])
    @error = "#{session[:username]} won!"
  else
    @error = "#{session[:username]} lost!"
  end
  session[:game_over] = true
  erb :game
end

post '/play_again' do
  name = session[:username]
  money = session[:player_money]
  session.clear
  session[:username] = name
  session[:player_money] = money
  redirect '/bet'
end

post '/quit' do
  erb :quit
end




