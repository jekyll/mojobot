# Description:
#   Tell Hubot to send a user a message when present in the room
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot tell <username> <some message> - tell <username> <some message> next time they are present
#
# Author:
#   christianchristensen

module.exports = (robot) ->
   robot.brain.data.tell_messages ?= {}
   localstorage = robot.brain.data.tell_messages
   robot.respond /tell ([\w.-]*) (.*)/i, (msg) ->
     datetime = new Date()
     tellmessage = msg.match[1] + ": " + msg.message.user.name + " @ " + datetime.toTimeString() + " said: " + msg.match[2] + "\r\n"
     if localstorage[msg.match[1]] == undefined
       localstorage[msg.match[1]] = tellmessage
     else
       localstorage[msg.match[1]] += tellmessage
     msg.send "@" + msg.message.user.name + ": Sodesu sensei sama!"
     return

   robot.hear /./i, (msg) ->
     # just send the messages if they are available...
     if localstorage[msg.message.user.name] != undefined
       tellmessage = localstorage[msg.message.user.name]
       delete localstorage[msg.message.user.name]
       msg.send tellmessage
     return

   ## irc HACK
   #robot.adapter.on 'join', (channel, who) ->
      #msg.send who

   #console.log robot.listeners
     #adapter.bot.addListener 'join', (channel, who) ->
     #console.log(who + " joined " + channel)
     #if localstorage[who]?
       #tellmessage = localstorage[who]
       #msg.send who + ": notifications pending."
     #return
    ## EOH

