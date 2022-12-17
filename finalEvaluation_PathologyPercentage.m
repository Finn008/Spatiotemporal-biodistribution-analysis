function [MouseInfoTime,PlaqueListSingle]=finalEvaluation_PathologyPercentage(TimeDistTable,MouseInfo,PlaqueList,PlaqueListSingle)
tic
global W;



PlaqueListSingle.Empire(:,1)=NaN;
PlaqueListSingle.PlaqueVolume(:,1)=NaN;

for Row=1:size(PlaqueListSingle,1)
    Plaque=PlaqueListSingle(Row,:);
    [Ind,Present]=findTDTind(TimeDistTable,Plaque.MouseId,Plaque.RoiId,3,'Volume1',Plaque.Pl,'Raw');
    if Present==0; continue; end;
    Data=TimeDistTable.Data{Ind,1}(:,Plaque.Time);
    PlaqueListSingle.Empire(Row,1)=nansum(Data,1);
    PlaqueListSingle.PlaqueVolume(Row,1)=nansum(Data(1:50),1);
end
MouseInfoTime=table;
for Mouse=1:size(MouseInfo,1)
    Selection=PlaqueListSingle(PlaqueListSingle.Mouse==Mouse,:);
    Timepoints=max(Selection.Time);
    for Time=1:Timepoints
        Selection2=Selection(Selection.Time==Time,:);
        TotalVolume=sum(Selection2.Empire);
        PlaqueVolume=sum(Selection2.PlaqueVolume);
        Ind=size(MouseInfoTime,1)+1;
        MouseInfoTime.MouseId(Ind,1)=MouseInfo.MouseId(Mouse);
        MouseInfoTime.TreatmentType(Ind,1)=Selection2.TreatmentType(1);
        MouseInfoTime.Mouse(Ind,1)=Mouse;
        MouseInfoTime.Time(Ind,1)=Time;
        MouseInfoTime.Age(Ind,1)=Selection2.Age(1);
        MouseInfoTime.Time2Treatment(Ind,1)=Selection2.Time2Treatment(1);
        MouseInfoTime.Filenames(Ind,1:2)=Selection2.Filenames(1,:);
        
        MouseInfoTime.TotalVolume(Ind,1)=TotalVolume;
        MouseInfoTime.PlaqueVolume(Ind,1)=PlaqueVolume;
        MouseInfoTime.PlaquePercentage(Ind,1)=PlaqueVolume/TotalVolume*100;
        
        
    end
end
disp(['finalEvaluation_PathologyPercentage: ',num2str(round(toc/60)),'min']);





return;
%% out
Loop=struct('Ind',0,'Selection',[]);
while Loop.Ind>=0
    Loop=struct('Type','TimeDistTable','TimeDistTable',TimeDistTable,'MouseInfo',MouseInfo,'Ind',Loop.Ind,'Selection',Loop.Selection,'Restriction',{{'Mod','Volume1';'Sub',2}});
    [Loop]=looper(Loop);
    if Loop.Ind<0; break; end
    Data=Loop.Data(:,Loop.NanCols);
    %     keyboard;
    %     A1=1;
    Table=table;
    Table.Radius=Loop.PlaqueData.Radius;
    Table(:,{'Empire','PlaqueVolume'})={NaN};
    
    Table.Empire(Loop.NanCols,1)=sum(Data,1).';
    Table.PlaqueVolume(Loop.NanCols,1)=sum(Data(1:50,:),1).';
    try
        MouseInfo.RoiInfo{Loop.Mouse}.TraceData{Loop.RoiData,1}.Data{Loop.Pl,1}(:,{'Empire','PlaqueVolume'})=Table(:,{'Empire','PlaqueVolume'});
    catch
        keyboard;
    end
end
A1=1;