require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN = 17

helpers do
  def calculate_total(cards)
    values = cards.map{ |card| card.last }
    total = 0
    values.each do |v|
      if v == 'A'
        total += 11
      else
        total += (v.to_i == 0 ? 10 : v.to_i)
      end
    end

    values.select{ |val| val == 'A' }.count.times do
      break if total <= BLACKJACK_AMOUNT
      total -= 10
    end

    total
  end

  def card_image(card)
    suit =  case card.first
              when 'H' then 'hearts'
              when 'D' then 'diamonds'
              when 'C' then 'clubs'
              when 'S' then 'spades'
            end

    value = card.last

    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card.last
                when 'J' then 'jack'
                when 'Q' then 'queen'
                when 'K' then 'king'
                when 'A' then 'ace'
              end 
    end

     "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def loser!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    session[:turn] = "dealer"
    session[:player_money] -= session[:current_bet].to_i
    @error = "#{msg}. <strong>#{session[:player_name]} lost!</strong>"
  end

  def winner!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    session[:turn] = "dealer"
    session[:player_money] += session[:current_bet].to_i
    @success = "#{msg}. <strong>#{session[:player_name]} won!</strong>"
  end

  def tie!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    session[:turn] = "dealer"
    @success = "#{msg}. <strong>It's a tie!</strong>"
  end
end

before do
  @show_hit_or_stay_buttons = true
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Please enter a valid name"
    halt erb(:new_player)
  end
    session[:player_name] = params[:player_name]
    session[:player_money] = 500
    redirect '/bet'
end

get '/bet' do
  erb :bet
end

post '/bet' do
  if params[:current_bet].empty? || params[:current_bet].to_i == 0
    @error = "Please enter a valid bet amount"
    halt erb(:bet)
  else
    session[:current_bet] = params[:current_bet]
    redirect '/game'
  end
end

get '/game' do
  session[:turn] = session[:player_name]

  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle!
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])

  if player_total == BLACKJACK_AMOUNT
    winner!("<strong>#{session[:player_name]}</strong> got <strong>blackjack!</strong>")
  elsif player_total > BLACKJACK_AMOUNT
    loser!("<strong>#{session[:player_name]}</strong> busted! <strong>Dealer</strong> had <strong>#{calculate_total(session[:dealer_cards])}</strong>")
  end
  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay!"
  @show_hit_or_stay_buttons = false
  
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"

  @show_hit_or_stay_buttons = false
  dealer_total = calculate_total(session[:dealer_cards])
  player_total = calculate_total(session[:player_cards])
  if dealer_total == BLACKJACK_AMOUNT
    loser!("<strong>#{session[:player_name]}</strong> stayed at <strong>#{player_total}</strong> and <strong>Dealer</strong> hit <strong>blackjack!</strong>")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("<strong>#{session[:player_name]}</strong> stayed at <strong>#{player_total}</strong> and <strong>Dealer</strong> busted with <strong>#{dealer_total}</strong>")
  elsif dealer_total >= DEALER_MIN
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end
  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])
  if player_total > dealer_total
    winner!("<strong>#{session[:player_name]}</strong> stayed at <strong>#{player_total}</strong> and <strong>Dealer</strong> stayed at <strong>#{dealer_total}</strong>")
  elsif dealer_total > player_total
    loser!("<strong>#{session[:player_name]}</strong> stayed at <strong>#{player_total}</strong> and <strong>Dealer</strong> stayed at <strong>#{dealer_total}</strong>")
  else
    tie!("String")
  end

  erb :game
end

post '/game_over' do
  redirect '/game_over'
end

get '/game_over' do
  erb :game_over
end


