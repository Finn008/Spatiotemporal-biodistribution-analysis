function [Speci]=variableExtract(String,Variables,StartEndSigns)

if exist('StartEndSigns')~=1
    StartEndSigns={'#';'|'};
end

StartPos=strfind(String,StartEndSigns{1}).';
EndPos=strfind(String,StartEndSigns{2}).';
if strcmp(StartEndSigns{1},'None')
    StartPos=zeros(size(EndPos,1),1);
end

if isempty(StartPos)
    Version=0;
else
    %     keyboard;
    Version=1;
    if size(StartPos,1)~=size(EndPos,1)
        Speci=[];
    end
end

%% new version
if Version==1
    if exist('Variables')==1
        for m=1:size(Variables,1)
            Path=['Speci.',Variables{m,1},'=0;'];
            eval(Path);
        end
    end
    
    Table=table;
    Table.VarStart=[0;EndPos(1:end-1)];
    Table.StartPos=StartPos;
    Table.EndPos=EndPos;
    for m=1:size(Table,1) % go through landmarks
        if Table.StartPos(m,1)==0
            for m2=1:size(Variables,1)
                Wave1=String(Table.VarStart(m)+1:Table.VarStart(m)+size(Variables{m2},2));
                if strcmp(Wave1,Variables{m2})
                    Table.StartPos(m,1)=Table.VarStart(m)+size(Variables{m2},2);
                    Table.Vars(m,1)=Variables(m2);
                    break;
                end
            end
        else
            Table.Vars(m,1)={String(Table.VarStart(m,1)+1:Table.StartPos(m,1)-1)};
        end
        
        Table.VariablesLength(m,1)=length(Table.Vars{m});
        Content=String(Table.StartPos(m,1)+1:EndPos(m,1)-1);
        ContentNum=str2num(Content);
        if isempty(ContentNum)
            Table.Content{m,1}=Content;
        else
            Table.Content{m,1}=ContentNum;
        end
        if isempty(Table.Vars{m,1})==0
            Path=['Speci.',Table.Vars{m,1},'=Table.Content{m,1};'];
            eval(Path);
        end
%         String=String(J.EndPos(m,1)+1:end);
    end
end
%% old version with landmarks provided
if Version==0
    for m=1:size(Variables,1) % go through landmarks
        landmarkLength=length(Variables{m});
        landmarkPos=strfind(String,Variables{m});
        if isempty(landmarkPos)
            Path=['Speci.',Variables{m},'=0;']; eval(Path);
            continue;
        end
        terminatorPos=strfind(String(landmarkPos:end),StartEndSigns{2})+landmarkPos-1;
        if terminatorPos(1)-(landmarkPos+landmarkLength)==0
            Path=['Speci.',Variables{m},'=1;']; eval(Path);
            continue;
        end
        
        wave2=String(landmarkPos+landmarkLength:terminatorPos(1)-1);
        wave3=str2num(wave2);
        if isempty(wave3)
            wave3=wave2;
        end
        Path=['Speci.',Variables{m},'=wave3;']; eval(Path);
        
    end
end