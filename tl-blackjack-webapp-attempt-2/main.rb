require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def calculate_total(cards)
    values = cards.map{ |card| card.last }
    total = 0
    values.each do |value|
      if value == "A"
        total += 11
      elsif value.to_i == 0
        total += 10
      else
        total += value.to_i
      end
    end
    values.select{ |val| val == "A" }.count.times do
      total -= 10 if total > 21
    end

    total
  end

  def create_image_path(card)
    suit =  case card.first
              when 'H' then 'hearts'
              when 'C' then 'clubs'
              when 'D' then 'diamonds'
              when 'S' then 'spades'
            end
    value = case card.last
              when 'J' then 'jack'
              when 'Q' then 'queen'
              when 'K' then 'king'
              when 'A' then 'ace'
              else card.last
            end
    path = "images/cards/#{suit}_#{value}.jpg"
  end
end

get '/' do
  if session[:username]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  session.clear
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  # Set up initial game values
  suits = ['H', 'D', 'S', 'C']
  values  = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'K', 'Q', 'A']
  session[:deck] = suits.product(values).shuffle!
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  # Render the game template
  erb :game
end

post '/player' do
  if params[:hit]
    redirect '/hit'
  else
    redirect '/stay'
  end
end

get '/hit' do
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) == 21
    @error = "Blackjack!"
  elsif calculate_total(session[:player_cards]) > 21
    @error = "Bust!"
  end
  erb :game
end

get '/stay' do
  redirect '/dealer'
end

get '/dealer' do
  session[:dealer_turn] = true
  erb :game
end

post '/dealer_hit' do
  if calculate_total(session[:dealer_cards]) < 17
    session[:dealer_cards] << session[:deck].pop
    if calculate_total(session[:dealer_cards]) == 21
      @error = "Blackjack!"
    elsif calculate_total(session[:dealer_cards]) > 21
      @error = "Bust!"
    end
  else
    @error = "Dealer total already 17 or higher"
  end
  erb :game
end



