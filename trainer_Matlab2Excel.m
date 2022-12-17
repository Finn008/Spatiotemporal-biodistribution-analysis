function trainer_Matlab2Excel()
% keyboard;
global W;
VocXls=xlsActxGet(W.Workbook,'Vocs',1);
VocXls.Selection=W.Voc.Selection(ismember2(VocXls.VocID,W.Voc.VocID));

for m=1:size(W.Voc,1)
    try
        W.Voc.Date(m,1)={datestr(W.Voc.Track{m}.Datenum(end),'dd.mm.yyyy')};
    end
end

VocXls.Date=W.Voc.Date(ismember2(VocXls.VocID,W.Voc.VocID));

excelWriteSparse(VocXls(:,{'Selection';'Date'}),W.Workbook,'Vocs','WholeColumns');



return;

VocList=xlsActxGet(W.Workbook,'Vocs',1);
W.Voc
excelWriteSparse(VocList(:,{'Selection'}),W.Workbook,'Vocs','WholeColumns');
W.Voc.VocID=cell2mat(W.Voc.VocID);
W.Voc.VocID=str2num(W.Voc.VocID);
W.Voc.VocID=cell2mat(W.Voc.VocID);
W.Voc.VocID=str2double(W.Voc.VocID);
W.Voc.VocID=uint32(W.Voc.VocID);
VocList.VocID=uint32(VocList.VocID);

VocList=xlsActxGet(W.Workbook,'Vocs',1);
[Wave1,Wave2]=ismember(W.Voc.VocID,VocList.VocID);
W.Voc.Selection(Wave2,1)=VocList.Selection(Wave2);

Wave1=table;
Wave1.VocID=W.Voc.VocID;
Wave1.Question=W.Voc.Question;
Wave1.Answer=W.Voc.Answer;
Wave1.Images=W.Voc.Images;
Wave1.Track=W.Voc.Track;
Wave1.Quality=W.Voc.Quality;
Wave1.Current=W.Voc.Current;
Wave1.Success=W.Voc.Success;
Wave1.Topic=W.Voc.Topic;
Wave1.Notes=W.Voc.Notes;
Wave1.ImageInfo=W.Voc.ImageInfo;
Wave1.Selection=W.Voc.Selection;
W.Voc=Wave1;