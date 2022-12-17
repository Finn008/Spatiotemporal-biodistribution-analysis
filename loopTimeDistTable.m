function [Loop]=loopTimeDistTable(Loop)
v2struct(Loop);
%% TimeDistTable
if exist('TimeDistTable')==1
    Ind=Ind+1;
    if exist('Restriction')==1 && exist('Selection')~=1
        for m=1:size(Restriction,1)
            if ischar(Restriction{m,2})
                Wave1(:,m)=strcmp(TimeDistTable{:,Restriction{m,1}},Restriction{m,2});
            elseif isnumeric(Restriction{m,2})
                Wave1(:,m)=TimeDistTable{:,Restriction{m,1}}==Restriction{m,2};
            end
        end
        Selection=find(sum(Wave1,2)==size(Wave1,2));
        Loop.Selection=Selection;
    end
    if Ind>size(Selection,1)
        Loop=struct('Ind',-1);
        return;
    end
    TDTind=Selection(Ind,1);
    Loop.TDTind=TDTind;
    Loop.MouseId=TimeDistTable.Mouse(TDTind,1);
    Loop.RoiId=TimeDistTable.Roi(TDTind,1);
    Loop.Sub=TimeDistTable.SubPool(TDTind,1);
    Loop.Mod=TimeDistTable.Mod{TDTind,1};
    Loop.Pl=TimeDistTable.Pl(TDTind,1);
    Loop.Calc=TimeDistTable.Calc{TDTind,1};
    Loop.Data=TimeDistTable.Data{TDTind,1}{:,:};
    
    Loop.NanCols=nansum(Loop.Data);
    Loop.NanCols=find(Loop.NanCols.'~=0);
    Loop.Ind=Ind;
    Loop.Mouse=find(MouseInfo.MouseId==Loop.MouseId);
%     Loop.RoiId=floor(Loop.RoiId);
%     Wave1=table2struct(TimeDistTable(TDTind,:));
    if strfind1({'Dystrophies1';'Autofluo1'},Loop.Mod,1)
        VolumeName='Volume1';
    elseif strfind1({'Boutons1Number'},Loop.Mod,1)
        VolumeName='Volume2';
    end
    
    [Wave1]=findTDTind(TimeDistTable,Loop.MouseId,Loop.RoiId,Loop.Sub,VolumeName,Loop.Pl,Loop.Calc);
    %     Ind=findTDTind(TimeDistTable,Wave1);
    Loop.VolumeData=TimeDistTable.Data{Wave1,1}{:,:};
    
    Loop.RoiData=find(MouseInfo.RoiInfo{Loop.Mouse,1}.Roi==floor(Loop.RoiId));
    Loop.TraceData=MouseInfo.RoiInfo{Loop.Mouse,1}.TraceData{Loop.RoiData}.Data{Loop.Pl,1};
    
    Loop.Age=MouseInfo.RoiInfo{Loop.Mouse}.Files{Loop.RoiData}.Age;
    
    StartTreatment=MouseInfo.StartTreatmentNum(Loop.Mouse);
    if StartTreatment==0
        Loop.TimeSections=[min(Loop.Age(:)),max(Loop.Age(:))+0.0001];
    else
        Loop.TimeSections=[min(Loop.Age(:)),StartTreatment];
        Loop.TimeSections(2,1:2)=[StartTreatment,max(Loop.Age(:))];
    end
end