function miceCounter()


Path2file='\\mitstor8.srv.med.uni-muenchen.de\ZNP-User\fipeter\Desktop\mistor8\aktuelle Dokumente\mice.xlsx';

[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path2file);
T=xlsActxGet(Workbook,'T');
Wave1=strfind1(T(:,1),'Remove');
Wave1(2,1)=strfind1(T(1,:).','Remove');
T=T(1:Wave1(1)-1,1:Wave1(2)-1);
T=cell2table(T(2:end,:),'VariableNames',T(1,:));
Groups=xlsActxGet(Workbook,'Groups');
Output=table;


% search double entries
MouseLines=unique(T.MouseLine);
for m=1:size(MouseLines,1)
    Wave1=T.Number(strfind1(T.MouseLine,MouseLines{m},1));
%     Wave1=cell2mat(Wave1);
    Wave2=unique(Wave1);
    if size(Wave1,1)~=size(Wave2,1)
        Wave3=histc(Wave1,0:max(Wave1));
        Wave4=find(Wave3>1);
        keyboard;
    end
end


TimeAxis=1:40;

% Jucker ex vivo
Sel=T(strfind1(T.APPPS1,'+T'),:);
Sel=Sel(strfind1(Sel.Location,'Crio'),:);
Sel(strfind1(Sel.TauKO,'K'),:)=[];

SubTable=table;
SubTable(1,{'Name','Sel'})={{'All'},{Sel}};
SubTable(2,{'Name','Sel'})={{'VKIN'},{Sel(strfind1(Sel.VKIN,'T',[],1),:)}};
SubTable(3,{'Name','Sel'})={{'GFPM'},{Sel(strfind1(Sel.GFPM,'T',[],1),:)}};
Sel(strfind1(Sel.GFPM,'T'),:)=[];
Sel(strfind1(Sel.VKIN,'T'),:)=[];
SubTable(4,{'Name','Sel'})={{'Stainless'},{Sel}};

[SubTable]=miceCounter_AgeHistogram(SubTable,TimeAxis);
Output(1,{'Name','Data'})={{'JuckerCrio'},{SubTable}};

% Jucker still living
Sel=T(strfind1(T.APPPS1,'+T'),:);
Sel(strfind1(Sel.TauKO,'K'),:)=[];
Sel=Sel(strfind1(Sel.Ddate,datestr(now,'dd.mm.yyyy')),:);
% TimeAxis=0:ceil(max(Sel.Age));

SubTable=table;
SubTable(1,{'Name','Sel'})={{'All'},{Sel}};
SubTable(2,{'Name','Sel'})={{'VKIN'},{Sel(strfind1(Sel.VKIN,'T',[],1),:)}};
SubTable(3,{'Name','Sel'})={{'GFPM'},{Sel(strfind1(Sel.GFPM,'T',[],1),:)}};
Sel(strfind1(Sel.GFPM,'T',[],1),:)=[];
Sel(strfind1(Sel.VKIN,'T',[],1),:)=[];
SubTable(4,{'Name','Sel'})={{'Stainless'},{Sel}};

[SubTable]=miceCounter_AgeHistogram(SubTable,TimeAxis);
Output(2,{'Name','Data'})={{'JuckerAlive'},{SubTable}};


% put together the final output
for m=1:size(Output,1)
    Ind=strfind1(Groups,Output.Name{m},1);
    Wave1=Output.Data{m};
    Groups(Ind(1)+1:Ind(1)+size(Wave1,1),Ind(2):size(Wave1,2))=Wave1;
end
xlsActxWrite(Groups,Workbook,'Groups');
keyboard;
return;










GroupInfo=xlsActxGet(Workbook,'GroupInfo',1);

Ind=strfind1(Groups,'G?|');

for Gr=1:size(Ind,1)
    Info2Add=Groups{Ind(Gr,1),Ind(Gr,2)}(4:end);
    %     Info2Add=struct2table(variableExtract(Info2Add));
    Info2Add=struct2table(variableExtract(Info2Add),'AsArray',1);
    
    Ind2=strfind1(Info2Add,'FindCol');
    if Ind2~=0
        for m=1:size(Ind2,1)
            Var=Info2Add.Properties.VariableNames{Ind2(m,2)};
            Wave2=strfind1(Groups(1:Ind(Gr,1),:),Var,1);
            eval(['Info2Add.',Var,'=',num2str(Groups{Wave2(end,1),Ind(Gr,2)}),';']);
        end
    end
    Ind2=strfind1(Info2Add,'FindRow');
    if Ind2~=0
        for m=1:size(Ind2,1)
            Var=Info2Add.Properties.VariableNames{Ind2(m,2)};
            eval(['Info2Add.',Var,'=Groups(Ind(Gr,1),1);']);
        end
    end
    GroupInfo(size(GroupInfo,1)+1,Info2Add.Properties.VariableNames)=Info2Add(1,Info2Add.Properties.VariableNames);
    Wave1=['GG',num2str(size(GroupInfo,1))];
    Groups(Ind(Gr,1),Ind(Gr,2))={Wave1};
    GroupInfo.Tag(end,1)={Wave1};
end


VariableNames=GroupInfo.Properties.VariableNames(3:end).';
for Gr=1:size(GroupInfo,1)
    try
        Sel=T;
        for Var=1:size(VariableNames,1)
            VarId=VariableNames{Var};
            if isempty(GroupInfo{Gr,VarId}{1})
                continue;
            end
                
            
            if strcmp(VarId,'AgeMin')
                Sel=Sel(Sel.Age>GroupInfo.AgeMin(Gr),:);
            elseif strcmp(VarId,'AgeMax')
                Sel=Sel(Sel.Age<=GroupInfo.AgeMax(Gr),:);
            elseif strcmp(VarId,'Genotype')
                Wave1=eval(GroupInfo.Genotype{Gr});
                Sel=Sel(strfind1(Sel.Genotype,Wave1),:);
            elseif strfind1(VarId,{'APPPS1';'VKIN';'GFPM';'dE9';'APP23';'TauKO'})
                Wave1=eval(GroupInfo.Genotype{Gr});
                Sel=Sel(strfind1(Sel.Genotype,Wave1),:);
                
                keyboard;
            end
        end
        GroupInfo.MouseCount(Gr,1)=size(Sel,1);
    catch
        GroupInfo.MouseCount(Gr,1)=NaN;
    end
end

for Gr=1:size(GroupInfo,1)
    Wave1=strfind1(Groups,GroupInfo.Tag{Gr},1);
    if Wave1~=0
        Groups(Wave1(1),Wave1(2))={GroupInfo.MouseCount(Gr)};
    end
end


xlsActxWrite(Groups,Workbook,'Groups');
% xlsActxWrite(Groups,Workbook,'Groups',[],'DeleteOnlyContent');
Excel.Visible = 1;
