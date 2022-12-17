function trainer_extractVocExcel2Matlab(VocIDs,VocList)
global W;

% VocList=xlsActxGet(W.Workbook,'Vocs',1);
[Wave1,Rows]=ismember(VocIDs,VocList.VocID);
VocList2add=VocList(Rows,:);
VocList2add.QuestionStr=VocList2add.Question;
VocList2add.AnswerStr=VocList2add.Answer;


[Out2]=getXlsCell_2('Vocs',W.Excel,{'Question';'Answer'},Rows+1);

VocList2add.Question=Out2.Question;
VocList2add.Answer=Out2.Answer;

[Wave1,Rows]=ismember(VocIDs,W.Voc.VocID);
Rows(Rows==0,1)=size(W.Voc,1)+1:size(W.Voc,1)+sum(Rows==0);
VariableNames=VocList2add.Properties.VariableNames;
W.Voc(Rows,VariableNames)=VocList2add(:,VariableNames);
% m=6; W.Voc(Rows,VariableNames(m))=VocList2add(:,VariableNames(m));
VocList.Update(:,1)=NaN;

% set update in ExcelTable to zero again
% excelWriteSparse(VocList(:,{'Update'}),W.Workbook,'Vocs','WholeColumns');

% delete all vocs in W.Voc that are not present anymore in Vokabelliste.xlsm
% W.Voc.QuestionStr(:,1)={'asdf'};
% W.Voc.AnswerStr(:,1)={'asdf'};


