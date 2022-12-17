function [NewVoc]=chooseVoc() % choose voc from Chunk2
global W;

% if size(W.Chunk2,1)<W.Chunk2Size && size(W.Chunk3,1)>0
for m=1:W.Chunk2Size-size(W.Chunk2,1)
%     keyboard; % fill up Chunk2 to 20
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
%     NewVoc=Selection.VocID(1);
    NewVoc=randomChooser(Selection.VocID);
end
% keyboard;
W.UndoneVoc=size(Selection,1)+size(W.Chunk,1);
W.TotalVoc=size(W.Chunk2,1);




return
% search vocs that donot show 3x success and last datenum > 24h
for m2=1:size(W.Voc,1)
    try
        W.Voc.Current(m2,1)=datenum(now)-W.Voc.Track{m2,1}.Datenum(end,1);
    catch
        W.Voc.Current(m2,1)=NaN;
    end
    try
        W.Voc.Success(m2,1)=size(W.Voc.Track{m2,1}.Success,1)-max(find(W.Voc.Track{m2,1}.Success~=1));
    catch
        W.Voc.Success(m2,1)=NaN;
    end
end
Range=table;
Selection=W.Voc(...
    W.Voc.Current>(24/12)&... % at least 12h break
    W.Voc.Success<3&... % less than 3 consecutive success
    W.Voc.Quality~=0,:); % quality not bad
% remove vocs that are already in Chunk
for m2=W.Chunk.VocID.'
    Wave1=find(Selection.VocID==m2);
    if isempty(Wave1)==0
        %             keyboard;
        Selection(Wave1,:)=[];
    end
end




% add vocs on specific topics
Wave1=strfind1(W.Voc.Topic,W.SelectedTopics);
%     Wave2=[Selection;W.Voc(Wave1,:)];
for m2=Wave1.'
    try
        Selection=[Selection;W.Voc(m2,:)];
    end
end

if size(Selection,1)>0
    [Wave1,Wave2]=max(Selection.Current);
    Ind=Selection.VocID(Wave2);
else
    Selection=W.Voc(...
        W.Voc.Current>1&... % at least 24h break
        W.Voc.Success<3&...
        W.Voc.Quality~=0&...
        find(W.Voc.VocID==W.Chunk.VocID)==0,:);
    Range=Selection.VocID.';
    Range = 1:size(W.Voc,1);            %# possible numbers
    %     Weight = ones(1,size(W.Voc,1));   %# corresponding weights
    Weight=(W.Voc.SuccessWeight.*W.Voc.Quality).';
    IntNumber = 1;              %# how many numbers to generate
    Ind = Range( sum( bsxfun(@ge, rand(IntNumber,1), cumsum(Weight./sum(Weight))), 2) + 1 );
end
W.Chunk.VocID(m,1)=Ind;
W.Chunk=W.Voc(W.Chunk.VocID,:);
%     W.Chunk.Question{m,1}=strjoin(W.Voc.Question{Ind,1}.Content.','');
% end