function extractVocXls(Type,ChosenTopic)
keyboard; % outdated
global W;
if size(W.Matlab2ExcelUpdate,1)>0
   Wave1=unique(W.Matlab2ExcelUpdate);
   msgbox(['Matlab2Excel: ',strjoin(Wave1(:),',')]);
end
PathChooser=0;
if PathChooser==1
    [FileName,PathName]=uigetfile('C:\Users\fipeter\Google Drive\Trainer\Vokabelliste.xlsm','Select File');
    PathVocXls=[PathName,FileName];
else
    PathVocXls=W.Path2Excel;
end

[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathVocXls);
Excel.Visible = 1;
% Sheet=1;

if strcmp(Type,'Excel2Matlab')
    Choice={'Question';'Answer';'Topic';'Images';'Quality';'Notes';'Selection'};
elseif strcmp(Type,'Matlab2Excel')
    Choice={'Topic';'Images';'Quality';'Notes'};
end
Fig=figure('Position',[20 20 150 250]);
Done=uicontrol('Position',[20 20 100 20],'String','Continue','Callback','uiresume(gcbf)');
Listbox=uicontrol('style','list','max',size(Choice,1),'min',1,'string',Choice,'Position',[20,45,100,180]);
uiwait(gcf);
Wave1=get(Listbox,'value');
close(Fig);
Choice=Choice(Wave1,1);
if strcmp(Type,'Excel2Matlab')
    [Out]=xlsActxGet(Excel,1,1,[]);
    Out.VocID=strtrim(cellstr(num2str(Out.VocID)));
    Out.Properties.RowNames=Out.VocID;
    if strfind1(Choice,{'Question';'Answer'},1)
        [Out2]=getXlsCell('Vocs','All',Excel);
        Out2=cell2table(Out2,'VariableNames',Out.Properties.VariableNames);
        Out2(1,:)=[];
        Out2.Properties.RowNames=Out.VocID;
        Out.Question=Out2.Question;
        Out.Answer=Out2.Answer;
    end
    
    
    for m=Out.VocID.'
        for Sel=Choice.'
            W.Voc(m,Sel{1})=Out(m,Sel{1});
        end
        W.Voc.Updated(m,1)=1;
    end
    % set VocIDs once more
    W.Voc(W.Voc.Updated==0,:)=[]; % delete all vocs in W.Voc that are not present anymore in Vokabelliste.xlsm
    W.Voc.Updated=[];
    
    W.Voc.VocID=W.Voc.Properties.RowNames;
    
    
    if strfind1(Choice,'Selection',1)
       [W.Chunk2]=fuseTable_2(W.Chunk2,W.Voc(W.Voc.Selection==1,:)); 
       W.Voc.Selection(:)=0;
    end
    
    
    saveVocs();
    
elseif strcmp(Type,'Matlab2Excel')
    [XlsData]=xlsActxGet(Excel,1,1,[]);
    VariableNames=varName2Col(XlsData.Properties.VariableNames.');
    % go through VocIDs in Excel
    VocIDs=strtrim(cellstr(num2str(XlsData.VocID)));
    XlsData.Properties.RowNames=VocIDs;
    for m=VocIDs.'
        Row=find(strcmp(VocIDs,m)==1)+1;
        for Sel=Choice.'
            Col=strfind1(XlsData.Properties.VariableNames.',Sel);
            Range=[num2abc(Col),num2str(Row)];
            if strfind1(W.Voc.Properties.RowNames,m)==0
                break
            end
            xlsActxWrite(W.Voc{m,Sel},Excel,'Vocs',Range);
        end
    end
    W.Matlab2ExcelUpdate=cell(0,1);
    Workbook.Save;
end
release(Workbook);
invoke(Excel, 'quit');
delete(Excel);



