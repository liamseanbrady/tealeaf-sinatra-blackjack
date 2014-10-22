## A Blackjack Game (using Sinatra)

This is a **learning project**. The sole purpose of this project was to be exposed to the statelessness of HTTP. **Sinatra is used** in contrast to Rails because it is closer to the metal and therefore makes stateless nature of HTTP more clear. A **cookie is used as the model**, and allows for some persitence.

This project was completed as an assignment as part of Tealeaf Academy's 'Introduction to Ruby and Web Development' course.

### Deployment

View the app live on Heroku [here](/)

### Game Design

  #### HTTP Routes Needed

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

  #### Helper Methods Needed

  - Calculate total of player and dealer cards
  - Winner, loser and tie methods

  #### UI Design

  - Clean
  - Easy for user to navigate

  #### Game Design

### Notes

  1. Make sure the 'sinatra' gem is installed.
  2. From the command line, you can start the server by 'ruby main.rb'
  3. If you have the 'shotgun' gem installed, you can instead run 'shotgun main.rb'
  4. ctrl+c to stop the server
