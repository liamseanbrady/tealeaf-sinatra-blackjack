require 'rubygems'
require 'sinatra'

set :sessions, true

MINIMUM_CHIPS = 50
MAXIMUM_CHIPS = 700
MINIMUM_BET = 50
BLACKJACK_AMOUNT = 21
DEALER_HIT_MINIMUM = 17

helpers do
  def calculate_total(cards)
    values = cards.map { |card| card.last }
    total = 0
    values.each do |v|
      if v == 'A'
        total += 11
      else
        total += (v.to_i == 0 ? 10 : v.to_i)
      end
    end

    values.select { |val| val == 'A' }.count.times do
      break if total <= BLACKJACK_AMOUNT
      total -= 10
    end

    total
  end

  def card_image(card)
    suit = case card.first
             when 'H' then 'hearts'
             when 'D' then 'diamonds'
             when 'C' then 'clubs'
             when 'S' then 'spades'
           end
    if card.last.to_i != 0
      value = card.last
    else
      value = case card.last
                when 'J' then 'jack'
                when 'Q' then 'queen'
                when 'K' then 'king'
                when 'A' then 'ace'
              end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def winner!(msg)
    @game_over = true
    @hide_dealer_first_card = false
    @show_hit_or_stay_buttons = false
    @show_dealer_hit_button = false
    @winner = "#{session[:player_name]} won. #{msg}"
    session[:player_money] += session[:current_bet].to_i
    session[:player_history] << "won"
  end

  def loser!(msg)
    @game_over = true
    @hide_dealer_first_card = false
    @show_hit_or_stay_buttons = false
    @show_dealer_hit_button = false
    @loser = "#{session[:player_name]} lost. #{msg}"
    session[:player_money] -= session[:current_bet].to_i
    session[:player_history] << "lost"

    if session[:player_money] <= MINIMUM_BET
      redirect '/game_over'
    end
  end

  def tie!(msg)
    @game_over = true
    @hide_dealer_first_card = false
    @show_hit_or_stay_buttons = false
    @show_dealer_hit_button = false
    @info = "It's a tie!. #{msg}"
    session[:player_history] << "tied"
  end
end

before do
  @show_hit_or_stay_buttons = true
  @hide_dealer_first_card = false
  @game_over = false
end

get '/' do
  redirect '/new_player'
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  session[:player_history] = []
  session[:player_gender] = params[:player_gender]
  session[:player_pronoun] = (session[:player_gender] == 'male' ? 'He' : 'She')
  if !params[:player_name].empty?
    session[:player_name] = params[:player_name]
    valid_name = true
  else
    @error = "Please enter a valid name"
  end
  if params[:player_money].to_i != 0 && params[:player_money].to_i >= MINIMUM_CHIPS && params[:player_money].to_i <= MAXIMUM_CHIPS
    session[:player_money] = params[:player_money].to_i
    valid_chips = true
  else
    @error = "Please enter a valid chip amount"
  end

  if valid_name && valid_chips
    redirect '/bet'
  else
    erb :new_player
  end
end

get '/bet' do
  erb :bet
end

post '/bet' do
  if params[:current_bet].to_i != 0 && params[:current_bet].to_i >= MINIMUM_BET && session[:player_money] >= params[:current_bet].to_i
    session[:current_bet] = params[:current_bet]
    redirect '/game'
  else
    @error = "Please enter a valid bet amount"
  end
    
  erb :bet
end

get '/game' do
  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle!
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  @hide_dealer_first_card = true

  if calculate_total(session[:player_cards]) == BLACKJACK_AMOUNT
    winner!("#{session[:player_pronoun]} hit blackjack!")
  end

  erb :game
end

post '/game/player/hit' do
  @hide_dealer_first_card = true

  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])

  if player_total == BLACKJACK_AMOUNT
    winner!("#{session[:player_pronoun]} hit blackjack!")
  elsif player_total > BLACKJACK_AMOUNT
    loser!("#{session[:player_pronoun]} busted and lost <strong>$#{session[:current_bet]}</strong>")
  end
  erb :game, layout: false
end

post '/game/player/stay' do
  redirect '/dealer'
end

get '/dealer' do
  @show_hit_or_stay_buttons = false

  dealer_total = calculate_total(session[:dealer_cards])
  player_total = calculate_total(session[:player_cards])

  if dealer_total == BLACKJACK_AMOUNT
    loser!("The dealer hit blackjack! #{session[:player_name]} was unlucky. #{session[:player_pronoun]} lost $#{session[:current_bet]}.")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("The dealer busted at #{dealer_total}. #{session[:player_name]} made a clever decision to stay at #{player_total}. #{session[:player_pronoun]} won $#{session[:current_bet]}.")
  elsif dealer_total >= DEALER_HIT_MINIMUM
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end

  erb :game, layout: false
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop

  redirect '/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false
  @show_dealer_hit_button = false

  dealer_total = calculate_total(session[:dealer_cards])
  player_total = calculate_total(session[:player_cards])

  if player_total > dealer_total
    winner!("#{session[:player_pronoun]} was wise and stayed at #{player_total} and the dealer stayed at #{dealer_total}. #{session[:player_name]} won $#{session[:current_bet]}.")
  elsif dealer_total > player_total
    loser!("#{session[:player_pronoun]} stayed at #{player_total} and the dealer stayed at #{dealer_total}. #{session[:player_name]} lost $#{session[:current_bet]}.")
  else
    tie!("#{session[:player_name]} and the dealer both stayed at #{player_total}.")
  end

  erb :game, layout: false
end

get '/game_over' do
  erb :game_over
end

get '/about' do
  erb :about
end



