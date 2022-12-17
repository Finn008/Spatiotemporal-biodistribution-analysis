function saveVocs()
global W;
if size(W.Matlab2ExcelUpdate,1)>0
   Wave1=unique(W.Matlab2ExcelUpdate);
   msgbox(['Matlab2Excel: ',strjoin(Wave1(:),',')]);
end


Data=struct;
Data.Voc=W.Voc;
Data.Chunk=W.Chunk;
Data.Chunk2=W.Chunk2;


Path=[W.Path2Backup,'\',datestr(datenum(now),'yyyy.mm.dd.HH.MM'),'_W.mat'];
% Path=['C:\Users\fipeter\Google Drive\Trainer\Backup\',datestr(datenum(now),'yyyy.mm.dd.HH.MM'),'_W.mat'];
% Path=['C:\Users\Admins\Desktop\Finns\Computer\Matlab\mfiles\home programs\trainer\backup\',datestr(datenum(now),'yyyy.mm.dd.HH.MM'),'_W.mat'];
save(Path,'Data');
Path=[W.Path2Backup,'\',datestr(datenum(now),'yyyy.mm.dd.HH.MM'),'_W.mat'];

copyfile(W.Path2Excel,[W.Path2Backup,'\Vokabelliste.xlsm'],'f');

save(W.Path2W,'Data');
% save('C:\Users\fipeter\Google Drive\Trainer\W.mat','Data');
% save('C:\Users\Admins\Desktop\Finns\Computer\Matlab\mfiles\home programs\trainer\W.mat','Data');
