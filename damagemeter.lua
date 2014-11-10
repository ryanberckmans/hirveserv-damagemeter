local globalDamageMeter = {}

local function cmdDamageMeterReport(client, args)
  local damageJustDone = tonumber( args )
  -- client:msg("%s%d", "Your damage meter script is working (probably :). You did this much damage (only precise when your target is level 31): ", damageJustDone)

  local clientName

  if client.user then
    clientName = client.user.name
  else
    clientName = client.name
  end

  if globalDamageMeter[clientName] == nil then
    globalDamageMeter[clientName] = 0
  end

  globalDamageMeter[clientName] = globalDamageMeter[clientName] + damageJustDone
end

-- https://stackoverflow.com/questions/2421695/first-character-uppercase-lua
function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

-- https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local function renderDamageMeter()
  local msg = {}
  
  local groupTotalDamage = 0

  for clientName, clientTotalDamage in pairs(globalDamageMeter) do
    groupTotalDamage = groupTotalDamage + clientTotalDamage
  end
  
  for clientName, clientTotalDamage in spairs(globalDamageMeter, function(t,a,b) return t[b] < t[a] end) do
    local clientPercentDamage = clientTotalDamage * 100.0 / groupTotalDamage
    table.insert(msg, string.format("#ly%12s #lg-     #w%4d%%", firstToUpper(clientName), clientPercentDamage))    
  end

  if #msg > 0 then
    table.insert(msg, 1, "#w        Name     % Total Damage\n--------------------------------")
    return table.concat(msg, "\n")
  else
    return "#w        (No Damage Recorded)"
  end
end

local function cmdDamageMeterAll(client)
  chat.msg("%s shows the damage meter:\n%s", client.name, renderDamageMeter())
end

local function cmdDamageMeter(client)
  client:msg("Showing the damage meter to just you:\n%s", renderDamageMeter())
end

local function cmdDamageMeterReset(client)
  globalDamageMeter = {}
  chat.msg("%s resets the damage meter.", client.name)
end

chat.command( "dm", "user", function(client)
  cmdDamageMeter(client)
end, "Show damage meter to just you")

chat.command( "dmall", "user", function(client)
  cmdDamageMeterAll(client)
end, "Show damage meter to all users")

chat.command( "dmreset", "user", function(client)
  cmdDamageMeterReset(client)
end, "Reset damage meter")

chat.command( "dmr", "user", {
  [ "^DamageMeterMagic Damage:(%d+) XpPerDamage:31$" ] = cmdDamageMeterReport,    
}, " --> Do not use this command. Damage Meter Script automated use only.", "do not use" )
