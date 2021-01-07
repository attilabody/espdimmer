local module = {}

function module.start()
  wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
      print("\nSTA -  CONNECTED".."\n\tSSID:  "..T.SSID.."\n\tBSSID: "..
      T.BSSID.."\n\tCHN:   "..T.channel)
    end)

  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
      print("\nSTA - GOT IP".."\n\tIP:   "..T.IP.."\n\tMASK: "..
      T.netmask.."\n\tGW:   "..T.gateway)
      app.start()
  end)

  wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
     print("\nSTA - DISCONNECTED".."\n\tSSID:   "..T.SSID.."\n\tBSSID:  "..
     T.BSSID.."\n\tReason: "..T.reason)
  end)

  wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function(T) print("STA - DHCP TIMEOUT") end)

  print("Connnecting to "..config.SSID.."...")
  wifi.setmode(wifi.STATION);
  wifi.sta.config({ssid = config.SSID, pwd = config.PWD})
  wifi.sta.connect()
end

return module
