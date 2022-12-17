function addTopic2Chunk(handles,ChosenTopic)
global W;
if exist('ChosenTopic')~=1
    % list topics in scroll down menu
    [AllTopics]=convert2stringArray(W.Voc.Topic);
    AllTopics=strjoin(AllTopics.',',');
    AllTopics=regexprep(AllTopics,' ','');
    AllTopics=strsplit(AllTopics,',').';
    AllTopics=unique(AllTopics);
    W.AllTopics=AllTopics;
    set(handles.taskChooser,'String',W.AllTopics);
    W.TaskChooserState='AddTopic2Chunk';
else
    Wave1=W.Voc.Topic;
    for m=1:size(Wave1)
        try
            Wave2=strsplit(Wave1{m,1},',');
            Wave1(m,1:size(Wave2,2))=Wave2;
        end
    end
    Voc2Add=strfind1(Wave1,ChosenTopic,1);
    Voc2Add=W.Voc(Voc2Add(:,1),:);
    if isfield(W,'Chunk2')
        [W.Chunk2]=fuseTable_2(W.Chunk2,Voc2Add);
    else
        W.Chunk2=Voc2Add;
    end
    if size(W.Chunk2,1)>W.Chunk2Size
        if isfield(W,'Chunk3')
            [W.Chunk3]=fuseTable_2(W.Chunk3,W.Chunk2(W.Chunk2Size+1:end,:));
        else
            W.Chunk3=W.Chunk2(W.Chunk2Size+1:end,:);
        end
        W.Chunk2(W.Chunk2Size+1:end,:)=[];
    end
    set(handles.taskChooser,'String',W.TaskChooserList,'Value',1);
    W.TaskChooserState='Main';
end
