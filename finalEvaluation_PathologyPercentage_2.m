function [MouseInfoTime,PlaqueListSingle,MouseInfo]=finalEvaluation_PathologyPercentage_2(MouseInfo,PlaqueListSingle,BinTableBoutons1,BinTableDystrophies)
% tic
global W;

GhostPlaques=find(PlaqueListSingle.Radius==0 | isnan(PlaqueListSingle.Radius));
Selection=PlaqueListSingle;Selection(GhostPlaques,:)=[];

% Dystrophies1
Ind=find(BinTableDystrophies.TimeBin==999 & BinTableDystrophies.TimeMin==-999 & BinTableDystrophies.RadBin==999 & isnan(BinTableDystrophies.Distance)==0);
BinTableDystrophies=BinTableDystrophies(Ind,:);
Data=BinTableDystrophies{:,strfind1(BinTableDystrophies.Properties.VariableNames.','Specification')+1:end};
Data(Data>100)=100;
Data=nanmedian(Data,2);
Dystrophies1=nan(256,1);
Dystrophies1(BinTableDystrophies.Distance+50)=Data;
Dystrophies1(find(Dystrophies1==0,1):end)=0;
Dystrophies1(isnan(Dystrophies1))=100;
Dystrophies1=Dystrophies1/100;

% Boutons1
Ind=find(BinTableBoutons1.TimeBin==999 & BinTableBoutons1.TimeMin==-999 & BinTableBoutons1.RadBin==999 & isnan(BinTableBoutons1.Distance)==0);
BinTableBoutons1=BinTableBoutons1(Ind,:);
Data=BinTableBoutons1{:,strfind1(BinTableBoutons1.Properties.VariableNames.','Specification')+1:end};
Data=nanmedian(Data,2);
Boutons1=nan(256,1);
Boutons1(BinTableBoutons1.Distance+50)=Data;
Boutons1=Boutons1/max(Boutons1(:))*100;
Boutons1(1:find(isnan(Boutons1)==0,1))=0;
Boutons1(isnan(Boutons1))=100;
Boutons1=1-Boutons1/100;

% VglutGreen
VglutGreen=nanmean(Selection.VglutGreen(:,1:50)).';
VglutGreen=1-VglutGreen/max(VglutGreen(:));
VglutGreen=[VglutGreen;zeros(206,1)];

PlaqueListSingle.Empire(:,1)=nansum(PlaqueListSingle.Volume1,2);
PlaqueListSingle.PlaqueVolume(:,1)=nansum(PlaqueListSingle.Volume1(:,1:50),2);

Wave1=PlaqueListSingle.Volume1.*repmat(Dystrophies1.',[size(PlaqueListSingle,1),1]);
PlaqueListSingle.DystrophicVolume(:,1)=nansum(Wave1,2);

Wave1=PlaqueListSingle.Volume1.*repmat(Boutons1.',[size(PlaqueListSingle,1),1]);
PlaqueListSingle.BoutonDevoidVolume(:,1)=nansum(Wave1,2);

Wave1=PlaqueListSingle.Volume1.*repmat(VglutGreen.',[size(PlaqueListSingle,1),1]);
PlaqueListSingle.DeadVolume(:,1)=nansum(Wave1,2);

% % % keyboard; % adjust such that it uses the already present MouseInfoTime variable
% pool for each mouse
MouseInfoTime=table;
for Mouse=1:size(MouseInfo,1)
    Selection=PlaqueListSingle(PlaqueListSingle.Mouse==Mouse,:);
    Ages=unique(Selection.Age);
    for Age=Ages.'
        Selection2=Selection(Selection.Age==Age,:);
        
        Ind=size(MouseInfoTime,1)+1;
        MouseInfoTime.MouseId(Ind,1)=MouseInfo.MouseId(Mouse);
        MouseInfoTime.TreatmentType(Ind,1)=Selection2.TreatmentType(1);
        MouseInfoTime.Mouse(Ind,1)=Mouse;
        MouseInfoTime.Age(Ind,1)=Selection2.Age(1);
        MouseInfoTime.Time2Treatment(Ind,1)=Selection2.Time2Treatment(1);
        MouseInfoTime.Filenames(Ind,1:2)=Selection2.Filenames(1,:);
        
        TotalVolume=sum(Selection2.Empire);
        MouseInfoTime.TotalVolume(Ind,1)=TotalVolume;
        MouseInfoTime.DeadPercentage(Ind,1)=sum(Selection2.DeadVolume)/TotalVolume*100;
        MouseInfoTime.PlaquePercentage(Ind,1)=sum(Selection2.PlaqueVolume)/TotalVolume*100;
        MouseInfoTime.DystrophicPercentage(Ind,1)=sum(Selection2.DystrophicVolume)/TotalVolume*100;
        MouseInfoTime.BoutonDevoidPercentage(Ind,1)=sum(Selection2.BoutonDevoidVolume)/TotalVolume*100;
    end
end



% interpolate missing timepoints
VariableNames={'DeadPercentage';'PlaquePercentage';'DystrophicPercentage';'BoutonDevoidPercentage';'TotalVolume'};
IndMissing=find(MouseInfoTime.TotalVolume==0);
IndMissing(find(IndMissing==size(MouseInfoTime,1)))=[];
for m=1:size(IndMissing,1)
    MouseInfoTime{IndMissing(m),VariableNames}=mean([MouseInfoTime{IndMissing(m)-1,VariableNames};MouseInfoTime{IndMissing(m)+1,VariableNames}],1);
end

for Mouse=1:size(MouseInfo,1)
    Wave1=MouseInfoTime.TotalVolume(MouseInfoTime.MouseId==MouseInfo.MouseId(Mouse));
    MouseInfo.VolumeMinMeanMax(Mouse,1:3)=[min(Wave1),mean(Wave1),max(Wave1)];
end
MouseId=279; Mouse=find(MouseInfo.MouseId==279);
MouseInfo.TotalVolume(Mouse,1)=min(MouseInfoTime.TotalVolume(MouseInfoTime.MouseId==MouseId));


