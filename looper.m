function [Loop]=looper(Loop)
v2struct(Loop);
% v2struct(In);
Ind=Ind+1;
%% TimeDistTable
if strcmp(Type,'TimeDistTable')
    if exist('Restriction')==1 && isempty(Selection)
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
    Loop.MouseId=TimeDistTable.MouseId(TDTind,1);
    Loop.RoiId=TimeDistTable.RoiId(TDTind,1);
    Loop.Sub=TimeDistTable.SubPool(TDTind,1);
    Loop.Mod=TimeDistTable.Mod{TDTind,1};
    Loop.Pl=TimeDistTable.PlId(TDTind,1);
    Loop.Calc=TimeDistTable.Calc{TDTind,1};
    Loop.Data=TimeDistTable.Data{TDTind,1}{:,:};
    
    Loop.NanCols=nansum(Loop.Data);
    Loop.NanCols=find(Loop.NanCols.'~=0);
    
    Loop.Mouse=find(MouseInfo.MouseId==Loop.MouseId);
    Loop.Roi=find(MouseInfo.RoiInfo{Loop.Mouse}.Roi==Loop.RoiId);
    %     Loop.RoiId=floor(Loop.RoiId);
    %     Wave1=table2struct(TimeDistTable(TDTind,:));
    if strfind1({'Volume1';'Dystrophies1';'Autofluo1';'MetBlue';'MetRed';'BRratio';'Plaque'},Loop.Mod,1)
        VolumeName='Volume1';
    elseif strfind1({'Volume2';'Boutons1Number';'VglutRed';'VglutGreen';'GRratio'},Loop.Mod,1)
        VolumeName='Volume2';
    else
        keyboard;
    end
    
    [Wave1]=findTDTind(TimeDistTable,Loop.MouseId,Loop.RoiId,Loop.Sub,VolumeName,Loop.Pl,Loop.Calc);
    %     Ind=findTDTind(TimeDistTable,Wave1);
    Loop.VolumeData=TimeDistTable.Data{Wave1,1}{:,:};
    
    Loop.RoiData=find(MouseInfo.RoiInfo{Loop.Mouse,1}.Roi==floor(Loop.RoiId));
    Loop.PlaqueData=MouseInfo.RoiInfo{Loop.Mouse,1}.TraceData{Loop.RoiData}.Data{Loop.Pl,1};
    
    Loop.Age=MouseInfo.RoiInfo{Loop.Mouse}.Files{Loop.RoiData}.Age;
    Loop.StartTreatmentNum=MouseInfo.StartTreatmentNum(Loop.Mouse);
    StartTreatment=MouseInfo.StartTreatmentNum(Loop.Mouse);
    if StartTreatment==0
        Loop.TimeSections=[min(Loop.Age(:)),max(Loop.Age(:))+0.0001];
    else
        Loop.TimeSections=[min(Loop.Age(:)),StartTreatment];
        Loop.TimeSections(2,1:2)=[StartTreatment,max(Loop.Age(:))];
    end
end

%% Mouse

if strcmp(Type,'MouseInfo')
    if isempty(Selection)
        Selection=table;
        for Mouse=1:size(MouseInfo,1)
            for Roi=1:size(MouseInfo.RoiInfo{Mouse,1},1)
                try 
                    PlaqueNumber=size(MouseInfo.RoiInfo{Mouse,1}.TraceData{Roi,1},1);
                catch
                    continue; % % PlaqueNumber=1;
                end
                for Pl=1:PlaqueNumber
                    Wave1=size(Selection,1)+1;
                    Selection.Mouse(Wave1,1)=Mouse;
                    Selection.Roi(Wave1,1)=Roi;
                    Selection.Pl(Wave1,1)=Pl;
                end
            end
        end
        Loop.Selection=Selection;
    end
    if Ind>size(Selection,1)
        Loop=struct('Ind',-1);
        return;
    end
    
    Loop.Mouse=Selection.Mouse(Ind,1);
    Loop.Roi=Selection.Roi(Ind,1);
    Loop.Pl=Selection.Pl(Ind,1);
    
    Loop.MouseId=MouseInfo.MouseId(Loop.Mouse);
    Loop.RoiInfo=MouseInfo.RoiInfo{Loop.Mouse,1};
    Loop.RoiId=Loop.RoiInfo.Roi(Loop.Roi);
    
    
    Loop.RoiData=find(MouseInfo.RoiInfo{Loop.Mouse,1}.Roi==Loop.RoiId);
    
    try; Loop.PlaqueData=MouseInfo.RoiInfo{Loop.Mouse,1}.TraceData{Loop.RoiData}.Data{Loop.Pl,1}; end;
    
    
    Loop.Age=MouseInfo.RoiInfo{Loop.Mouse}.Files{Loop.RoiData}.Age;
    Loop.Filenames=MouseInfo.RoiInfo{Loop.Mouse}.Files{Loop.RoiData}.Filenames;
    Loop.TreatmentType=MouseInfo.TreatmentType{Loop.Mouse};
    Loop.StartTreatmentNum=MouseInfo.StartTreatmentNum(Loop.Mouse);
    
    StartTreatment=MouseInfo.StartTreatmentNum(Loop.Mouse);
    if StartTreatment==0
        Loop.TimeSections=[min(Loop.Age(:)),max(Loop.Age(:))+0.0001];
    else
        Loop.TimeSections=[min(Loop.Age(:)),StartTreatment];
        Loop.TimeSections(2,1:2)=[StartTreatment,max(Loop.Age(:))];
    end
    
    
end
%% finish
Loop.Ind=Ind;