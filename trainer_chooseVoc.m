function [NewVoc]=trainer_chooseVoc() % choose voc from Chunk2
global W;

for m=1:W.Chunk2Size-size(W.Chunk2,1)
    if isfield(W,'Chunk3') && size(W.Chunk3,1)>0
        keyboard;
        W.Chunk2=fuseTable_2(W.Chunk2,W.Chunk3(1,:));
        W.Chunk3(1,:)=[];
    end
end

W.Chunk2=W.Voc(W.Chunk2.VocID,:);
Selection=W.Voc(W.Chunk2.VocID,:);
% remove vocs that are already in Chunk
for m=W.Chunk.VocID.'
    try
        Selection(m,:)=[];
    end
end

for m=Selection.VocID.'
    try
        Selection.Current(m,1)=datenum(now)-Selection.Track{m,1}.Datenum(end,1);
    catch
        Selection.Current(m,1)=datenum(now);
    end
end
% remove vocs that have been worked on in the last 3 hours
Selection(Selection.Current<(3/24),:)=[];
if size(Selection,1)==0
    NewVoc=[];
else
    NewVoc=randomChooser(Selection.VocID);
end
W.UndoneVoc=size(Selection,1)+size(W.Chunk,1);
W.TotalVoc=size(W.Chunk2,1);