# Description:
#   Inspect the data in redis easily
#
# Commands:
#   hubot show users - Display all users that hubot knows about
#   hubot show storage - Display the contents that are persisted in the brain


Util = require "util"

module.exports = (robot) ->
  robot.respond /show storage$/i, (msg) ->
    output = Util.inspect(robot.brain.data, false, 4)
    reply_to =  msg.message.user.name
    msg.send "sending a memory dump via PM to " + reply_to
    robot.adapter.reply { user: { reply_to: reply_to, name: reply_to }}, output

  robot.respond /show users$/i, (msg) ->
    response = ""

    for own key, user of robot.brain.data.users
      response += "#{user.id} #{user.name}"
      response += " <#{user.email_address}>" if user.email_address
      response += "\n"

    msg.send response

