function trainer_displaySuccess()
global W;
handles = findall(0,'type','figure','Name','trainer'); handles=guidata(handles);

% Show Success in textbox
Track=W.Voc.Track{W.VocInd};
Wave1='';
for m=1:size(Track,1)
    if Track.Success(m,1)==-1;
        String2Add='.';
    elseif Track.Success(m,1)==1;
        String2Add='|';
    else
        String2Add='?';
    end
    Wave1=[Wave1,String2Add];
end
% % % Wave1=[Wave1,' ',num2str(W.UndoneVoc),'/',num2str(W.TotalVoc)];
set(handles.text3,'String',Wave1);