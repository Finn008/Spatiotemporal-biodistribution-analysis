function setParameters_2(Value,Pos,Version)
if exist('Version')==0
    Version=1;
end

if Version==1
    inputemu('normal',Pos.Ch1);
    inputemu({'key_normal';'\END'}); inputemu(repmat({'key_normal';'\BACKSPACE'},[1,10]));
    inputemu('key_normal',Val.Ch1Wavelength); pause(1);
end