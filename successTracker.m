function trainer_successTracker(Success,handles)
global W;

Track=W.Voc.Track{W.VocInd};

if isempty(Track) || datenum(now)-Track.Datenum(end,1)>W.LearnInterval % if no entry present yet or no entry within last 24h
    if istable(Track)==0
        Track=table;
    end
    TrInd=size(Track,1)+1;
    Track.Datenum(TrInd,1)=datenum(now);
    Track.Success(TrInd,1)=Success;
    for m=1:size(Track,1)
        Track.Evaluation(m,1)=sum(Track.Success(1:m,1));
    end
end


W.Voc.Track{W.VocInd}=Track;
displaySuccess();
if Success==1
    % replace voc with one from Chunk2
    W.Chunk(1,:)=[];
end



% % show Track
% Track.Time=datenum(now)-Track.Datenum;
% for m=1:size(Track,1)
%     Track.Evaluation(m,1)=sum(Track.Success(1:m,1));
% end
% W.Voc.Track{W.VocInd}=Track;
% axes(handles.axes1);
% plot(Track.Time,Track.Evaluation,'.r','MarkerSize',5);
% axis([-90,0,-5,5]);
% set(gca,'YTick',[]);
% set(gca,'XTick',[]);

