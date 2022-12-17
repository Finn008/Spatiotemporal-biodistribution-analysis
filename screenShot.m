function screenShot(Path2file,Filename,ComputerName)
Filename=[Filename,'.jpg'];
inputemu('key_normal','\PRINTSCREEN'); pause(4);
CDpath=['cd(''C:\Windows\System32'');']; eval(CDpath);
!mspaint.exe &
pause(2);
inputemu('key_ctrl','v'); pause(1.5);
inputemu('key_ctrl','s'); pause(1.5);
clipboard('copy',Filename); pause(2);
inputemu('key_ctrl','v'); pause(1);

inputemu('key_down','\SHIFT'); pause(0.5);
if strcmp(ComputerName,'gnp454n')
    inputemu(repmat({'key_normal';'\TAB'},[1,6]),0.5);
else
    inputemu(repmat({'key_normal';'\TAB'},[1,7]),0.5);
end

inputemu('key_up','\SHIFT'); pause(0.5)
inputemu('key_normal',' '); pause(2);

clipboard('copy',Path2file); pause(2);
inputemu('key_ctrl','v'); pause(1.5);

inputemu('key_normal','\ENTER'); pause(1.5);
inputemu('key_normal','\ENTER'); pause(1.5);
inputemu('key_normal','\ENTER'); pause(1.5);
inputemu('key_normal','\ENTER'); pause(1.5);
pause(5); inputemu('key_alt','\F04');
