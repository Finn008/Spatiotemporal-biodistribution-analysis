function trainer_showVoc(Type)
global W;

if size(W.Chunk,1)==0
    keyboard;
    W.JEditbox.setText('All vocs finished!');
    return;
end
if strcmp(Type,'Question')
    % update order of vocs
    Wave1=W.Voc(find(isnan(W.Voc.Selection)==0),:);
    Wave1=sortrows(Wave1,'Selection');
    Wave1.Selection=(1:size(Wave1,1)).';
    W.Voc.Selection(ismember2(Wave1.VocID,W.Voc.VocID))=Wave1.Selection;
    
    W.VocInd=find(W.Voc.Selection==1);
    W.VocID=W.Voc.VocID(W.VocInd);
    Input=W.Voc.Question{W.VocInd};
    Input.Content(end+1,1)={'###'};
    trainer_displaySuccess()
elseif strcmp(Type,'Answer')
    Input1=W.Voc.Question{W.VocInd};
    Input2=W.Voc.Answer{W.VocInd};
    Input1.Content(end+1,1)={'<br>'};
    Input1.Content(end+1,1)={'###'};
    Input1.Content(end+1,1)={'<br>'};
    Input=[Input1;Input2];
end

% change parameters
Wave1=variableSetter_2('',{'VocID',num2str(W.VocID);'Quality',num2str(W.Voc.Quality(W.VocInd));'Notes',W.Voc.Notes{W.VocInd};'Topic',W.Voc.Topic{W.VocInd};'Images',W.Voc.Images{W.VocInd}});
W.OrigStoreChanges=variableExtract(Wave1);
Wave1=['###',Wave1,'###'];
Input.Content(end+1,1)={'<br>'};
Input.Content(end+1,1)={Wave1};

if isempty(W.Voc.Images{W.VocInd})==0 && ischar(W.Voc.Images{W.VocInd})
    Wave1=eval(['{''',W.Voc.Images{W.VocInd},'}']);
    ImageInfo=array2table(Wave1,'VariableNames',{'Name';'Width';'Height'});
    W.Voc.ImageInfo(W.VocInd)={ImageInfo};
else
    ImageInfo=table;
end

[HtmlStr]=htmlCoder(Input,ImageInfo);
W.JEditbox.setWrapping(true);
W.JEditbox.setText(HtmlStr); % alternative: jEditbox.setContentType('text/html');