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
  redirect '/bet'
end

get '/bet' do
  session[:player_money] = 500
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

post '/deal_card' do
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) > 21
    @error = "#{session[:username]} went bust! #{session[:username]} lost!"
  end
  erb :game
end


