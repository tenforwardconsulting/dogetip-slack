# dogetip-slack
#### A Dogecoin tipping bot for [Slack](https://slack.com)

# Setup
1.  Install dogecoind on your server

  1. Usually this is done on linux by building from [source](https://github.com/dogecoin/dogecoin)
  2. Be sure to edit dogecoin.conf to set your rpcuser and rpcpassword
  3. Launch dogecoind -daemon and wait for the blockchain to sync

2. Clone this repo on your server

3. run `bundle install`

4. Set up the Slack integration: as an "outgoing webhook" (https://example.slack.com/services/new/outgoing-webhook)

  1. Write down the api token they show you in this page
  2. Set the trigger word: we use "dogetipper" but doesn't matter what you pick
  3. Set the Url to the server you'll be deploying on http://example.com:4567/tip

4. Launch the server!

  `DOGECOIN_USER=rpcuser DOGECOIN_PASSWORD=rpcpassword SLACK_API_TOKEN=YOURSLACKTOKENHERE bundle exec ruby tipper.rb -p 4567`
  

# Commands

* Tip - send dogecoin!

  `dogetipper tip @somebody 100`
  `dogetipper tip @somebody random`

* Deposit - put dogecoin in

  `dogetipper deposit`

* Withdraw - take dogecoin out

  `dogetipper withdraw DKzHM7rUB2sP1dgVskVFfdSoysnojuw2pX 100`

* Balance - find out how much is in your wallet

  `dogetipper balance`

* Networkinfo - Get the output of getinfo.  Note:  this will disclose the entire aggregate balance of the hot wallet to everyone in the chat

  `dogetipper networkinfo`

# Security

## This runs an unencrypted hot wallet on your server.  ***This is not even close to secure.***  You should not store significant amounts of dogecoin in this wallet.  Withdraw your tips to an offline wallet often. 
