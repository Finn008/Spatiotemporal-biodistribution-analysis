function dontSleep()

for m=1:9999999999999999999999999999999999
    inputemu('move',[100;100]);
    pause(0.5);
    inputemu('move',[200;200]);
    pause(60*30);
end