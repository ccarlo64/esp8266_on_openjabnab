dofile("config.lua");
mac=''
pwd='123456789012'
pwdx=''
cnonce=''
text={}
idx=1;
BTN_PIN = 7
gpio.mode(BTN_PIN,gpio.INT, gpio.PULLUP)
btn=false
gpio.mode(5, gpio.OUTPUT )
gpio.mode(6, gpio.OUTPUT )
LED_R=1
LED_G=2
LED_B=3
gpio.mode(LED_R, gpio.OUTPUT )
gpio.mode(LED_G, gpio.OUTPUT )
gpio.mode(LED_B, gpio.OUTPUT )

tableColor={0,1,2,3,4,5,6,7}
color=6
rled=false
gled=false
bled=false
function setColor(c)
  x=tableColor[c]
  rled=bit.isset(x, 2)
  gled=bit.isset(x, 1)
  bled=bit.isset(x, 0)
end
function ledStop()
 pwm.stop(LED_R)
 pwm.stop(LED_G)
 pwm.stop(LED_B)
 pwm.setduty(LED_R, 0)
 pwm.setduty(LED_G, 0)
 pwm.setduty(LED_B, 0)
 iled=0
 inc=10
end
function ledStart()
    if rled then
      pwm.start(LED_R)
    end
    if gled then
      pwm.start(LED_G)
    end
    if bled then
      pwm.start(LED_B)
    end
end
function led(i)
    if rled then
      pwm.setduty(LED_R, i)
    end
    if gled then
      pwm.setduty(LED_G, i)
    end
    if bled then
      pwm.setduty(LED_B, i)
    end
end
pwm.setup(LED_R, 100, 256)
pwm.setup(LED_G, 100, 256)
pwm.setup(LED_B, 100, 256)
ledStop()
dofile("lcd.lua").cls();
dofile("lcd.lua").home();
dofile("lcd.lua").cursor(0);
tmpn=0
function btnint(level )
  gpio.trig(BTN_PIN)
  if tmpn==0 then
   conn:send(btn_text)
   print("button: "..btn_text) 
   btn=true  
  else
   tmpn=tmpn+1
   print(".")
   if tmpn>100 then
     tmpn=0
   end
  end  
end

function setPassword()
 for i=1,12,1 do 
   a=tonumber( string.sub(mac,i,i),16 )
   b=string.char(string.byte(pwd,i))
   c=bit.bxor(a,b)
   d=string.format("%x", c)
   pwdx=pwdx..d
 end
end
function setText()
text[1] = "<?xml version='1.0' encoding='UTF-8'?><stream:stream to='"..h.."' xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0'>"
text[2] = "<iq type='get' id='1'><query xmlns='violet:iq:register'/></iq>"
text[3] = "<iq to='"..h.."' type='set' id='2'><query xmlns=\"violet:iq:register\"><username>"..mac.."</username><password>"..pwdx.."</password></query></iq>"
text[4] = "<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='DIGEST-MD5'/>"
text[5] = ""
text[6] = "<response xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>"
text[7] = "<?xml version='1.0' encoding='UTF-8'?><stream:stream to='"..h.."' xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0'>"
text[8]='<iq from="'..mac..'@'..h..'/" to="'..h..'" type=\'set\' id=\'1\'><bind xmlns=\'urn:ietf:params:xml:ns:xmpp-bind\'><resource>Boot</resource></bind></iq>'
text[9]='<iq from="'..mac..'@'..h..'/boot" to="'..h..'" type=\'set\' id=\'2\'><session xmlns=\'urn:ietf:params:xml:ns:xmpp-session\'/></iq>'
text[10]='<iq from=\''..mac..'@'..h..'/boot\' to=\'net.violet.platform@'..h..'/sources\' type=\'get\' id=\'3\'><query xmlns="violet:iq:sources"><packet xmlns="violet:packet" format="1.0"/></query></iq>'
text[11]='<iq from=\''..mac..'@'..h..'/boot\' to="'..h..'" type=\'set\' id=\'4\'><bind xmlns=\'urn:ietf:params:xml:ns:xmpp-bind\'><resource>idle</resource></bind></iq>'
text[12]='<iq from=\''..mac..'@'..h..'/idle\' to=\''..h..'\' type=\'set\' id=\'5\'><session xmlns=\'urn:ietf:params:xml:ns:xmpp-session\'/></iq>'
text[13]='<presence from=\''..mac..'@'..h..'/idle\' id=\'6\'></presence>'
text[14]='<iq from=\''..mac..'@'..h..'/boot\' to=\''..h..'\' type=\'set\' id=\'7\'><unbind xmlns=\'urn:ietf:params:xml:ns:xmpp-bind\'><resource>boot</resource></unbind></iq>'
btn_text='<message from=\''..mac..'@'..h..'/idle\' to=\''..h..'\' id=\'26\'><button xmlns="violet:nabaztag:button"><clic>1</clic></button></message>'
end
function go()
  conn = net.createConnection(net.TCP, 0)
  conn:on("receive", function(sck, c)
    print("step "..idx.." receive: "..c)
    
    if idx > 14 then 
          
     b = string.match(c,'<message[^>]*><packet[^>]*>([^<]*)</packet></message>') 
     if b then 
      d = encoder.fromBase64(b)
      r = crypto.toHex(d)           
      a = dofile("decode.lua").decry( r )
      dofile("lcd.lua").cls();
      dofile("lcd.lua").home(); 
      dofile("lcd.lua").lcdprint("received cmd",1,0);            
      if string.sub(r,1,4)=='7f04' then
       msg=""
       typepck = string.sub(r,19,20)    
       if typepck=='09' or typepck=='21' then
        a = string.sub(r,21,22)
        color=1+tonumber(a,16) 
        msg="set color "..color
        tmr.stop(2)
        ledStop()
        setColor(color)
        ledStart()
        tmr.start(2)
       elseif typepck=='04' then
        a = tonumber(string.sub(r,21,22),16)
        b = tonumber(string.sub(r,25,26),16)
        msg="ears l:"..a.." r:"..b
       else
        msg=string.sub(r,1,12).."..."
       end
       dofile("lcd.lua").lcdprint(msg,2,0);
      else
       dofile("lcd.lua").lcdprint(string.sub(a,1,16),2,0);
       print(a)
      end 
     end
     if btn then
      btn=false
      gpio.trig(BTN_PIN, "down", btnint)
     end
    end 
    if idx == 14 then
     dofile("lcd.lua").lcdprint("connected to",1,0);
     dofile("lcd.lua").lcdprint(h,2,0);
     setColor(color)
     ledStart()
     tmr.alarm(2, 100, tmr.ALARM_SEMI, function()
      tmr.stop(2)
      led(iled)
      iled=iled+inc 
      if iled>255 or iled <1 then
       inc = inc * -1
      end  
      tmr.start(2)
     end)      
     b = string.match(c,'<message[^>]*><packet[^>]*>([^<]*)</packet></message>') 
     if b then 
      d = encoder.fromBase64(b)
      r = crypto.toHex(d)
      print("extra message boot packet: "..r)
     end
    end 

    if idx==10 then
      b = string.match(c,'<iq[^>]*><query[^>]*><packet[^>]*>([^<]*)</packet></query></iq>') 
      d = encoder.fromBase64(b)
      r = crypto.toHex(d)
      print("boot packet: "..r)
    end
    
    if idx==4 then
      print("found")
      b = string.match(c,'<challenge[^>]*>(.+)</challenge>') 
      if b ~= '' then
       a = dofile("decode.lua").deco(b,h,mac,pwd);
       text[idx+1] = '<response xmlns="urn:ietf:params:xml:ns:xmpp-sasl">'..a..'</response>'     
      end
    end    
    --gia registrato
    if already then
      if idx==1 then
        idx=3
      end
      if idx==5 then
        b = string.match(c,'<challenge[^>]*>(.+)</challenge>') 
        if b == nil then
         idx=idx+1
        end
      end
    end
    idx=idx+1
    if idx < 15 then
      conn:send(text[idx])
      print("send pt2: "..idx.." "..text[idx]) 
    end
    if idx > 14 then
        tmr.alarm(1, 10000, 1, function()                  
         tmr.stop(1)      
         m='<presence from=\''..mac..'@'..h..'/idle\' id=\''.."123"..'\'></presence>'
         conn:send(m)
         print("ping send: "..idx.." "..m) 
        end)    
    end
  end )
  conn:on("connection", function() 
    print("connected") 
   conn:send(text[idx])
   print("send: "..text[idx]) 
  end)
  conn:connect(5222,h)
end

wifi.setmode(wifi.STATION)
--DHCP     
--OR
--STATIC
wifi.sta.setip({ip=IPADR,netmask=IPMASK,gateway=IPROUTER})
wifi.sta.config(SSID,PW)

wifi.sta.connect()

tmr.alarm(3, 500, 1, function()
     if wifi.sta.getip() == nil then
        print("Connecting...")
     else
        tmr.stop(3)
        --find username
        x = wifi.sta.getmac()
        mac = string.gsub(x, ":", "")
        print("IP:"..wifi.sta.getip().." MAC:"..mac )
        setPassword()
        setText()
        go()
        gpio.trig(BTN_PIN, "down", btnint)
     end
end)
