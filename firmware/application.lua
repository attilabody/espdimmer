local module = {}
local m = nil
local pt = tmr.create()
local rt = tmr.create()

local function on_message_received(conn, topic, data)
  if data ~= nil then
    print(topic .. ": " .. data)
    -- do something, we have received a message
  end
end

local function on_client_connected(client)
  m:subscribe(config.ENDPOINT .. config.ID, 0,
    function(conn) print("Successfully subscribed to data endpoint") end
  )
  pt:unregister()
  pt:alarm(5000, tmr.ALARM_AUTO,
    function() m:publish(config.ENDPOINT .. "ping","id=" .. config.ID,0,0) end
  )
end

local function on_client_cannot_connect(client, reason)
  print("Cannot connect to MQTT gateway "..config.HOST..".")
  rt:alarm(10000, tmr.ALARM_SINGLE, function()
      m:connect(config.HOST, config.PORT, false, on_client_connected, on_client_cannot_connect)
  end)
end

local function mqtt_start()
  if m == nil then
    m = mqtt.Client(config.ID, 120)
    -- register message callback beforehand
    m:on("message", on_message_received) 
    m:on("offline", function(client)
        print("offline")
        pt:unregister()
        mqtt_start()
    end)
  else
    rt:unregister()
    m:close()
  end
  -- Connect to broker
  m:connect(config.HOST, config.PORT, false, on_client_connected, on_client_cannot_connect)
end

function module.start()
  mqtt_start()
end

return module
