function spotBasedDriftFinder(ListA,ListB,FitCoef,FileinfoA,FileinfoB)

ListA.CenterOfMass=ListA.CenterOfMass-repmat(FileinfoA.Um{1}.'/2,[size(ListA,1),1]);
Wave1=FitCoef-FileinfoB.Um{1}/2;
ListB.CenterOfMass=ListB.CenterOfMass+repmat(Wave1.',[size(ListB,1),1]);

% A1=[ListB(10680,:);ListA(283,:)];
% A1.CenterOfMass(2,1:3)=A1.CenterOfMass(2,1:3)-FileinfoA.Um{1}.'/2-FitCoef.';

ListA.Id=(1:size(ListA,1)).';
ListB.Id=(1:size(ListB,1)).';
if size(ListA,1)>2000
    
    ListA=sortrows(ListA,'Volume','descend');
    ListA=ListA(1:4000,:);
elseif size(ListB,1)>4000
    
    ListB=sortrows(ListB,'Volume','descend');
    ListB=ListB(1:4000,:);
end
% A1=[ListB(find(ListB.Id==10680),:);ListA(283,:)];






WaveA=permute(ListA.CenterOfMass,[1,3,2]);
WaveB=permute(ListB.CenterOfMass,[3,1,2]);
DistXYZ=repmat(WaveA,[1,size(ListB,1)])-repmat(WaveB,[size(ListA,1),1]);

DistTotal=(sum(DistXYZ.^2,3)).^0.5;

MaxDistance=30;
CenterOfMass=table;
for Spot=1:size(ListA,1)
%     A1=min(DistTotal(Spot,:));
    WithinRange=find(DistTotal(Spot,:)<MaxDistance).';
    Table=ListB(WithinRange,:);
    Table.VolumeDiff=abs(Table.Volume-ListA.Volume(Spot));
    Table=sortrows(Table,'VolumeDiff');
    Nselect=min(5,size(Table,1));
    Data2add=Table.CenterOfMass(1:Nselect,1:3);
    ListA.Tracks(Spot,1)={Data2add};
    Data2add=table(repmat(ListA.CenterOfMass(Spot,3),[size(Data2add,1),1]),Data2add,'VariableNames',{'Depth';'CenterOfMass'});
    CenterOfMass=[CenterOfMass;Data2add];
end
keyboard;

figure; plot(CenterOfMass.Depth,CenterOfMass.CenterOfMass(:,1),'.');
figure; plot(CenterOfMass.Depth,CenterOfMass.CenterOfMass(:,2),'.');
figure; plot(CenterOfMass.Depth,CenterOfMass.CenterOfMass(:,3),'.');


