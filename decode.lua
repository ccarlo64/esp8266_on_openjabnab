local M
do

local function deco(b,h,mac,pwddata)
   local value = {}
   print ("decode")
   local d = encoder.fromBase64(b)
   local nonce = string.match(d,'nonce=\"(.+)\",qop')
   local nc="00000001"
   local cnonce=""
   for i=1,13,1 do 
    d=math.random(0,9) 
    cnonce=cnonce..d
   end
   cnonce = cnonce..string.char(0)
   local digest_uri="xmpp/"..h
   local algo = "md5"
   local tmp = mac .. "::" .. pwd 
   local c1 = crypto.hash(algo, tmp)
   local c2 = crypto.hash(algo, (c1 .. ":" .. nonce .. ":" .. cnonce))
   local HA1 = crypto.toHex(c2)
   local mode="AUTHENTICATE"
   tmp = mode .. ":" .. digest_uri
   local c3 = crypto.hash(algo, tmp)
   local HA2=crypto.toHex(c3)    
   tmp = HA1 .. ":" .. nonce .. ":" .. nc .. ":" .. cnonce .. ":auth:" .. HA2
   local c4 = crypto.hash(algo, tmp)
   local response= crypto.toHex(c4)
   local other = ',nc='..nc..',qop=auth,digest-uri="'..digest_uri..'",response='..response..',charset=utf-8'
   responce = 'username="'..mac..'",nonce="'..nonce..'",cnonce="'..cnonce..'"'..other 
   tmp= crypto.toBase64(responce)       
  
   return tmp
end

function decry ( o )
 if string.sub(o,1,4)=='7f0a' then
  o = string.sub(o,11)
  local currentChar = 35
  local x=""
  local a=0
  local b=0
  local code=0
  for i=3,string.len(o),2 do
    a = string.sub(o,i,i+1)
    code=tonumber(a,16) 
    currentChar = ((code -47)*(1+2*currentChar))%256
    x=x..string.char(currentChar)
  end
  return x    
 else
  return o
 end
end
 

M={
deco=deco,
decry=decry,
}
end
return M

