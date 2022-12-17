function showVoc(Type)
keyboard;
global W;
handles = findall(0,'type','figure','Name','trainer'); handles=guidata(handles);
for m=1:5-size(W.Chunk,1)
    keyboard;
    VocID=chooseVoc();
    if isempty(VocID)
        break;
    end
        W.Chunk=fuseTable_3(W.Chunk,W.Voc(VocID(1),:));
end
if size(W.Chunk,1)==0
    keyboard;
    W.JEditbox.setText('All vocs finished!');
    return;
end
if strcmp(Type,'Question')
    W.VocInd=W.Chunk.VocID(1);
    Input=W.Voc.Question{W.VocInd};
    Input.Content(end+1,1)={'###'};
    displaySuccess()
elseif strcmp(Type,'Answer')
    Input1=W.Voc.Question{W.VocInd};
    Input2=W.Voc.Answer{W.VocInd};
    Input1.Content(end+1,1)={'<br>'};
    Input1.Content(end+1,1)={'###'};
    Input1.Content(end+1,1)={'<br>'};
    Input=[Input1;Input2];
end

% change parameters
Wave1=variableSetter_2('',{'Quality',num2str(W.Voc.Quality(W.VocInd));'Notes',W.Voc.Notes{W.VocInd};'Topic',W.Voc.Topic{W.VocInd};'Images',W.Voc.Images{W.VocInd}});
W.OrigStoreChanges=variableExtract(Wave1);
Wave1=['###',Wave1,'###'];
% Input.Content(end+1,1)={'<br>'};
Input.Content(end+1,1)={'<br>'};
Input.Content(end+1,1)={Wave1};

if isempty(W.Voc.Images{W.VocInd})==0
    Wave1=eval(['{''',W.Voc.Images{W.VocInd},'}']);
    ImageInfo=array2table(Wave1,'VariableNames',{'Name';'Width';'Height'});
    W.Voc.ImageInfo(W.VocInd)={ImageInfo};
else
    ImageInfo=table;
end

[HtmlStr]=htmlCoder(Input,ImageInfo);
W.JEditbox.setWrapping(true);
W.JEditbox.setText(HtmlStr); % alternative: jEditbox.setContentType('text/html');