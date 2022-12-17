function [Out]=detectKeyPress()

clipboard('copy','zero');
!notepad.exe "C:\Windows\System32" &
pause(2);
inputemu('key_normal','\ENTER'); % nicht-berechtigt wegklicken
inputemu('key_normal','test');

inputemu({'key_down';'\SHIFT'}); pause(0.5);
inputemu({'key_normal';'\HOME'}); pause(0.5);
inputemu({'key_up';'\SHIFT'}); pause(0.5);
inputemu('key_ctrl','c'); pause(0.5);
CurrentValue=clipboard('paste'); pause(0.5);

if strcmp(CurrentValue,'zero') %NumLock on
    inputemu({'key_normal';'\NUMLOCK'}); pause(0.5);
    Out.NumLock=1;
    inputemu({'key_normal';'\END'}); pause(0.5);
    inputemu({'key_down';'\SHIFT'}); pause(0.5);
    inputemu({'key_normal';'\HOME'}); pause(0.5);
    inputemu({'key_up';'\SHIFT'}); pause(0.5);
    inputemu('key_ctrl','c'); pause(0.5);
    CurrentValue=clipboard('paste'); pause(0.5);
else
    Out.NumLock=0;
end

if strcmp(CurrentValue,'TEST') %NumLock on
    inputemu({'key_normal';'\CAPSLOCK'}); pause(0.5);
    Out.CapsLock=1;
elseif strcmp(CurrentValue,'test') %NumLock on
    Out.CapsLock=0;
else
    keyboard;
end
inputemu('key_alt','\F04'); pause(1);
inputemu('key_normal','n');