request = require 'request-promise'
PRIVACY = process.env.PRIVACY
ACCESS_TOKEN = process.env.ACCESS_TOKEN
LOG_ROOM = process.env.LOG_ROOM

module.exports = (robot) ->
  check_excluded = (link) ->
    excluded = robot.brain.get("excluded")?.split("|") or []
    for ex in excluded
      return false if link.includes(ex)
    true
  robot.hear /シェア/i, (res) ->
    links = res.message.text.match(/https?:\/\/[^\s]+/ig) || []
    links = links.filter (link) -> check_excluded(link)

    Promise.all links.map (link) ->
      robot.messageRoom LOG_ROOM, "Sharing #{link}"
      request.post
        url: "https://graph.facebook.com/v2.9/me/feed?access_token=#{ACCESS_TOKEN}",
        form: link: link, privacy: PRIVACY
      .then ->
        robot.messageRoom LOG_ROOM, "Shared #{link}"
        Promise.resolve()
      .catch (error) ->
        robot.messageRoom LOG_ROOM, "Failed!", error


  robot.respond /add to exclude list\s+(.+)/, (res) ->
    excluded = robot.brain.get("excluded")?.split("|") or []
    link = res.match[1]
    excluded.push res.match[1] if (excluded.indexOf(link) < 0)
    robot.brain.set "excluded", excluded.join("|")

  robot.respond /show excluded list/, (res) ->
    res.reply robot.brain.get("excluded").join("\n")

  robot.respond /remove from excluded list\s+(.+)/, (res) ->
    excluded = robot.brain.get("excluded")?.split("|") or []
    link = res.match[1]
    list = excluded.reduce (prev, cur) ->
      cur.push prev unless prev.includes link
    , []
    robot.brain.set "excluded", list.join("|")
