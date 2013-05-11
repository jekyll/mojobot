#! /bin/bash

echo "I'm assuming you have not created an Heroku instance or anything."
read -p "Are you _sure_ about this?"
echo "Ok, here goes."

heroku create --stack cedar
heroku addons:add redistogo:nano
heroku config:add HUBOT_HISTORY_LINES=10000
heroku config:add HUBOT_IRC_SERVER="irc.freenode.net"
heroku config:add HUBOT_IRC_ROOMS="#jekyll"
heroku config:add HUBOT_IRC_NICK="mojo"
git push heroku master
heroku ps:scale app=1
