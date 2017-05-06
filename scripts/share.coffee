module.exports = (robot) ->
  robot.hear /シェア[^]+(https?:\/\/[^\s]+)/i, (res) ->
    link = res.match[1]
    excluded = robot.brain.get("excluded")?.split("|") or []
    res.send "test #{res.match[1]}" if excluded.reduce (prev, cur) -> cur or prev.includes link
    , false

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
