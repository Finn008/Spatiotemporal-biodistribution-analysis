function killImaris(Report)
global W;
[status,cmdout] = dos('taskkill /f /im Imaris.exe');
if exist('Report')==1
else
    disp(cmdout);
end
[status,cmdout] = dos('taskkill /f /im ImarisServerIce.exe');
