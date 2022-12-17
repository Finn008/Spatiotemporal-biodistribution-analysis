function [W]=initializeTrainer(handles)
global W;
W=struct;

set(handles.edit1,'Max',5);
JScrollPane = findjobj(handles.edit1); % Get the Java scroll-pane container reference
JViewPort = JScrollPane.getViewport;
W.JEditbox = JViewPort.getComponent(0);
W.JEditbox.setEditorKit(javax.swing.text.html.HTMLEditorKit);

% Path2Vokabeln='\\fs-mu.dzne.de\petersf\aktuelle Dokumente\Vokabeln';
% Path2Vokabeln={'C:\Users\Admin.000\OneDrive - med.uni-muenchen.de\LabAktuell\Vokabeln'};
Path2Vokabeln={'C:\Users\Admin.000\OneDrive\Finns\Arbeit\LabAktuell\Vokabeln'};


for m=1:size(Path2Vokabeln,1)
    if exist(Path2Vokabeln{m})==7
        Path2Vokabeln=Path2Vokabeln{m};
    end
end

W.Path2Excel=[Path2Vokabeln,'\Vokabelliste.xlsm'];
W.Path2W=[Path2Vokabeln,'\W.mat'];
W.Path2Images=[Path2Vokabeln,'\Images'];
W.Matlab2ExcelUpdate=cell(0,1);
% W.Path2Backup='\\fs-mu.dzne.de\petersf\aktuelle Dokumente\Vokabeln\Backup';
W.Path2Backup=[Path2Vokabeln,'\Backup'];

if exist(W.Path2Backup)==7
else
    keyboard;
    W.Path2Backup='C:\Users\Admin\Desktop\Finns\Backup\Vokabeln';
end
Wave1=load(W.Path2W);

[W.Excel,W.Workbook,Sheets,SheetNumber]=connect2Excel(W.Path2Excel);
W=catstruct(W,Wave1.Data);

W.ChunkSize=5;
W.Chunk2Size=100;
W.VocStatus=1;
W.LearnInterval=3/24;
W.TaskChooserList={'Initialize','SaveVocs','Excel2Matlab','Matlab2Excel','ChooseTopic','OpenExcel'};
set(handles.taskChooser,'String',W.TaskChooserList);
W.TaskChooserState='Main';

RatingMenuList={'Quality';'OutChunk2';'StoreChanges'};
set(handles.ratingMenu,'String',RatingMenuList);
addpath W.Path2Images;

% update vocabulary to be updated
VocList=xlsActxGet(W.Workbook,'Vocs',1);

if size(unique(VocList.VocID),1)~=size(VocList,1)
    keyboard; % there are duplettes in VocList
end
W.Voc.Images=convert2stringArray(W.Voc.Images);

VocList.Images=convert2stringArray(VocList.Images);
VocList.Answer=convert2stringArray_2(VocList.Answer);

% remove vocs that are present in W.Voc but not in the VocList-Exceltable
W.Voc(ismember(W.Voc.VocID,VocList.VocID)==0,:)=[];
% A1=ismember(VocList.VocID,W.Voc.VocID);


VocList.QuestionStr(ismember2(W.Voc.VocID,VocList.VocID),1)=W.Voc.QuestionStr;
VocList.AnswerStr(ismember2(W.Voc.VocID,VocList.VocID),1)=W.Voc.AnswerStr;
% keyboard;
% VocList.ImagesOld(ismember2(W.Voc.Images,VocList.Images),1)=W.Voc.Images;
VocList.ImagesOld(ismember2(W.Voc.VocID,VocList.VocID),1)=W.Voc.Images;
VocList.ImagesOld=convert2stringArray(VocList.ImagesOld);

VocList.Update(strcmp(VocList.Question,VocList.QuestionStr)~=1|strcmp(VocList.Answer,VocList.AnswerStr)~=1|strcmp(VocList.Images,VocList.ImagesOld)~=1,1)=1;
% VocList.Test(strcmp(VocList.Answer,VocList.AnswerStr)~=1,1)=1;

VocIDs=VocList.VocID(VocList.Update==1);
if isempty(VocIDs)==0
    trainer_extractVocExcel2Matlab(VocIDs,VocList);
end
W.Voc.Selection(ismember2(VocList.VocID,W.Voc.VocID),1)=VocList.Selection; % specifies the positions within Array2 of the IDs found in Array1 
