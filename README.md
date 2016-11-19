# Ghostwriters App

This is an app written in the Corona SDK in Lua (https://coronalabs.com/corona-sdk/).

This app requires the webapp to be running (e.g. in Heroku). See corresponding [Ghostwriters Webapp](https://github.com/charlescapps/ghostwriters-webapp).

I enjoyed this project and spent a long time on it in the evenings over 6 months. It's quite a fun game. It's 2 player multiplayer, has leaderboards, and has single player mode. 

The gameplay is a lot like Scrabble, but plays more like reverse scrabble with different rules. The game starts with a random board (with real words on it), and players begin by grabbing tiles. There are also special power-ups e.g. the "Scry Tile" to find a good move. 

The game has in-app payments, however players get 1 token per hour for free, and can store up to 10 tokens, making it easy to play forever without paying any money for the less hardcore players.

I shut down the servers earlier this year, because the backend doesn't run well on Heroku Hobby due to all the Tries in memory for the dictionaries, and it didn't make much money in in-app payments (about $80 total for Android plus iOS).

So unfortunately it's not up and running now, but maybe eventually I'll start a server if I can find cheaper hosting that's sufficiently fast with enough memory, and is easy to maintain like Heroku.

The code is probably sub-par in some ways since I learned Lua for this project and I didn't pull in too many libs. However, at least I arrived at a decent pattern for re-using Lua classes for UI widgets. 
