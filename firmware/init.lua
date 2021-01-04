pwm.setup(3, 1000, 5)
pwm.setup(4, 1000, 5)
pwm.start(3)
pwm.start(4)

LED1_actual = 5
LED1_value = 5
LED1_delta = 1
LED2_actual = 5
LED2_value = 5
LED2_delta = 1

tmr1 = tmr.create()
tmr2 = tmr.create()

function calctimer(StartValue, EndValue, Duration)
  Delta = math.abs(EndValue - StartValue);
  if Delta >= Duration then
    Delay = 1
    Step = (EndValue - StartValue) / Duration
  else
    if StartValue < EndValue then Step = 1
    else Step = -1 end
    Delay = Duration / Delta
  end
  return Delay, Step
end

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
    print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
    T.BSSID.."\n\tChannel: "..T.channel)
    end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("\n\tSTA - GOT IP".."\n\tIP: "..T.IP.."\n\tMASK: "..
    T.netmask.."\n\tGW: "..T.gateway)
    end)


wifi.setmode(wifi.STATION)
wifi.sta.config({ssid="iotwifi", pwd="iotpassword"})
 
srv = net.createServer(net.TCP) 
srv:listen(80,function(conn) 
  conn:on("receive",function(conn,payload) 
    print("Input: "..payload)

    local iter = payload:gmatch("[^\r\n]+")
    local request = iter()

    local LED = tonumber(string.match(request,".*LED%s*=%s*(%d+)"))
    local Duration = tonumber(string.match(request,".*Duration%s*=%s*(%d+)"))
    local Value = tonumber(string.match(request,".*Value%s*=%s*(%d+)"))
    local StepDelay

    if request:sub(1,3) == "GET" and Value ~= nil and LED ~= nil then

      if Duration == nil then Duration = 0 end
      Value = math.min(1023, Value)

      print("Received command for LED"..LED.." - Value: "..Value.." Duration: "..Duration)

      if LED == 1 then
        if LED1_actual ~= Value then
          LED1_value = Value

          if Duration == 0 then
            pwm.setduty(3, LED1_value)
            LED1_actual = LED1_value
          else
            StepDelay, LED1_delta = calctimer(LED1_actual, LED1_value, Duration)

            print("Starting transition from "..LED1_actual.." to "..LED1_value..". Delta is "..LED1_delta..", delay is "..StepDelay..".")

            tmr1:alarm(StepDelay, tmr.ALARM_AUTO, function()
              LED1_actual = LED1_actual + LED1_delta
              if LED1_delta < 0 then LED1_actual = math.max(LED1_actual, LED1_value) -- correct possible underflow
              else LED1_actual = math.min(LED1_actual, LED1_value) end               -- correct possible overflow
              if(LED1_actual == LED1_value) then
                tmr1:stop()
                print ("LED1 transition finished at "..LED1_actual..".")
              end
              pwm.setduty(3, LED1_actual)
            end )
          end
        end
  
      elseif LED == 2 then 
        if LED2_actual ~= Value then
          LED2_value = Value

          if Duration == 0 then
            pwm.setduty(4, LED2_value)
            LED2_actual = LED2_value
          else
            StepDelay, LED2_delta = calctimer(LED2_actual, LED2_value, Duration)

            print("Starting transition from "..LED2_actual.." to "..LED2_value..". Delta is "..LED2_delta..", delay is "..StepDelay..".")

            tmr2:alarm(StepDelay, tmr.ALARM_AUTO, function()
              LED2_actual = LED2_actual + LED2_delta
              if LED2_delta < 0 then LED2_actual = math.max(LED2_actual, LED2_value) -- correct possible underflow
              else LED2_actual = math.min(LED2_actual, LED2_value) end               -- correct possible overflow
              if(LED2_actual == LED2_value) then
                tmr2:stop()
                print ("LED2 transition finished at "..LED2_actual..".")
              end
              pwm.setduty(4, LED2_actual)
            end )
          end
        end
      end
    end
    local response = "OK\r\n"
    conn:send("HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=UTF-8\r\nAccept-Ranges: none\r\nContent-Length: ")
    conn:send(response:len().."\r\n\r\n")
    conn:send(response)
  end )
end )

print ("LED dimmer on "..wifi.sta.getmac().." running...")
