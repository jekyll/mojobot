# Description:
#   Allows Hubot to store a recent chat history for services like IRC that
#   won't do it for you.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_HISTORY_LINES
#   HUBOT_LOG_SERVER_HOST
#   HUBOT_LOG_SERVER_TOKEN
#
# Commands:
#   hubot show history [<lines>] - Shows <lines> of history, otherwise all history
#   hubot clear history - Clears the history
#
# Author:
#   wubr (modified for IRC by mattetti, modified to log to separate server by parkr)

http        = require('http')
querystring = require('querystring')

class History
  constructor: (@robot, @keep) ->
    @cache = {}
    @robot.brain.on 'loaded', =>
      if @robot.brain.data.history
        @robot.logger.info "Loading saved chat history"
        @cache = @robot.brain.data.history

  add: (room, message) ->
    @cache[room] ?= []
    @cache[room].push message
    @logEntryExternally(room, message)
    while @cache.length > @keep
      @cache.shift()
    @robot.brain.data.history = @cache

  show: (room, lines) ->
    @cache[room] ?= []
    if (lines > @cache[room].length)
      lines = @cache[room].length
    reply = 'Showing ' + lines + ' lines of history:\n'
    reply = reply + @entryToString(message) + '\n' for message in @cache[room][-lines..]
    return reply

  entryToString: (event) ->
    return '[' + event.hours + ':' + event.minutes + '] ' + event.name + ': ' + event.message

  clear: ->
    @cache = {}
    @robot.brain.data.history = @cache

  logEntryExternally: (room, event) ->
    if process.env.HUBOT_LOG_SERVER_TOKEN and process.env.HUBOT_LOG_SERVER_HOST
      process.nextTick ->
        data = querystring.stringify
          token: process.env.HUBOT_LOG_SERVER_TOKEN,
          room:  room,
          text:  event.message,
          author: event.name,
          time:  event.time.toUTCString()

        opts =
          host: process.env.HUBOT_LOG_SERVER_HOST,
          port: 80,
          path: "/api/messages/log",
          method: 'POST',
          headers:
            'Content-Type': 'application/x-www-form-urlencoded',
            'Content-Length': data.length

        try
          req = http.request opts, (res) ->
            res.setEncoding('utf8')
            res.on 'data', (chunk) ->
              console.log("Response: #{chunk}")

          req.on 'error', (e) ->
            console.error(e)

          req.write(data)
          req.end()
        catch e
          console.error(e)

class HistoryEntry
  constructor: (@room, @name, @message) ->
    @time = new Date()
    @hours = @time.getHours()
    @minutes = @time.getMinutes()
    if @minutes < 10
      @minutes = '0' + @minutes

module.exports = (robot) ->

  options =
    lines_to_keep:  process.env.HUBOT_HISTORY_LINES

  unless options.lines_to_keep
    options.lines_to_keep = 50

  history = new History(robot, options.lines_to_keep)

  robot.hear /(.*)/i, (msg) ->
    historyentry = new HistoryEntry(msg.message.room, msg.message.user.name, msg.match[1])
    history.add msg.message.room, historyentry

  robot.respond /show history\s*(\d+)?/i, (msg) ->
    if msg.match[1]
      lines = msg.match[1]
    else
      lines = history.keep
    reply_to =  msg.message.user.name
    msg.send "Sending room history to " + reply_to + " via PM"
    console.log "sending a history PM to " + reply_to
    robot.adapter.reply { user: { reply_to: reply_to, name: reply_to }}, history.show(msg.message.room, lines)

  robot.respond /clear history/i, (msg) ->
    msg.send "Eh, sorry mate. Can't clear the history."
    # history.clear()
