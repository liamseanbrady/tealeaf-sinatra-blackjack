# A Blackjack Game (using Sinatra)

This is a **learning project**. The sole purpose of this project was to be exposed to the statelessness of HTTP. **Sinatra is used** in contrast to Rails because it is closer to the metal and therefore makes stateless nature of HTTP more clear. A **cookie is used as the model**, and allows for some persitence.

This project was completed as an assignment as part of Tealeaf Academy's 'Introduction to Ruby and Web Development' course.

View a blog post about my experience of building this app [here](http://www.liamseanbrady.wordpress.com)

## Deployment

View the app live on Heroku [here](https://flatjack-app.herokuapp.com/)

## Skills Required

- Building a web app end-to-end from specification to deployment.
- Ruby
- Understanding of HTTP
- Sinatra
- HTML
- CSS & Twitter Bootstrap

## Game Design

### Routes Needed (HTTP)

- **GET**
  - /
  - /new_player
  - /bet
  - /game
  - /game/dealer
  - /game_over

- **POST**
  - /new_player
  - /bet
  - /game/player/hit
  - /game/player/stay
  - /game/dealer/hit

### Helper Methods Needed

- Calculate total of player and dealer cards
- Winner, loser and tie methods

### UI Design

- Clean
- Easy for user to navigate

### Game Flow

1. Player enters their name and what value of chips they want to buy.
2. Player places a bet.
3. Player is dealt two cards, and dealer is deal two cards. (One 52-card deck).
  - Did player hit blackjack? If yes, then exit.
4. Player can hit or stay. They can keep taking a card until their card total is 21 or above.
  - Did player hit blackjack or go bust? If yes, then exit.
5. If the player stays, then it is the dealer's turn.
  - Did dealer hit blackjack? If yes, then exit.
6. The dealer takes a card until their total is >= 17.
  - - Did dealer hit blackjack or go bust? If yes, then exit.
7. If the dealer's total is between 17 and 21, compare the totals of dealer's and player's cards.
8. The highest total wins. 
9. If player wins, then they get back their bet * 2, and if they lose, they get their bet * 2 deducted from their money.

### High-level Design Strategy

- Four separate pages:
  1. Page with form to set new player and buy chips.
  2. Page with form to set bet for a round.
  3. Page for main gameplay.
  4. Game over plage with player's final money total and exit message.

- All pages include a navigation bar which allows the player to start afresh at any time.

- Maintain suspense by allowing player to control flow of dealer taking cards until its card total reaches 17 or higher.

### Edge Cases

- Player entering invalid name (e.g, empty string).
- Hiding dealer's first card until the player's turn is over.
- Player betting above the money they have available, or entering a negative number.
- Player not meeting minimum bet for a round, or exceeding bet maximum for a round.


## Notes

  1. Make sure the 'sinatra' gem is installed.
  2. From the command line, you can start the server by 'ruby main.rb'
  3. If you have the 'shotgun' gem installed, you can instead run 'shotgun main.rb'
  4. ctrl+c to stop the server
