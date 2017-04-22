gpio.mode(5, gpio.OUTPUT )
gpio.mode(6, gpio.OUTPUT )
dofile("lcd.lua").cls();
dofile("lcd.lua").home();
dofile("lcd.lua").cursor(0);
NextFile="emu.lua"
l = file.list();
for k,v in pairs(l) do
--  print("name:"..k..", size:"..v)
     if k == NextFile then
     dofile("lcd.lua").lcdprint("Starting...",1,0);  
     dofile("lcd.lua").lcdprint("please wait..",2,0);  
     print("Wait 5 seconds please")
     tmr.alarm(0, 5000, 0, function() dofile(NextFile) end)
     print("Started file ".. NextFile)
     else
   --  do nothing
     end
end
print(".")   
