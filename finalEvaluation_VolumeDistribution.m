function [MouseInfoTime]=finalEvaluation_VolumeDistribution(MouseInfo,MouseInfoTime,PlaqueListSingle)
% keyboard;
global W;
% % % for Bin=1:size(MouseInfoTime,1)
% % %     MouseId=MouseInfoTime.MouseId(Bin);
% % %     Age=MouseInfoTime.Age(Bin);
% % %     Selection=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & PlaqueListSingle.Age==Age,:);
% % %     Volume=nansum(Selection.Volume1,1);
% % %     MouseInfoTime.Volume1(Bin,1:256)=Volume;
% % % end


TimeBins=(-28:7:63).'; TimeBins(:,2)=TimeBins(:,1)+7;
TimeBins(:,3)=7;TimeBins(:,4)=mean(TimeBins(:,1:2),2)/7;
TimeBins=array2table(TimeBins,'VariableNames',{'TimeMin','TimeMax','TimeBinning','TimeMean'});

% keyboard; % make more general
DistBins=(DistanceMinMax(1):DistanceBinning:DistanceMinMax(2)-DistanceBinning).'; DistBins(:,2)=DistBins(:,1)+DistanceBinning;
DistBins(:,3)=DistanceBinning;DistBins(:,4)=mean(DistBins(:,1:2),2);
DistBins=array2table(DistBins,'VariableNames',{'DistMin','DistMax','DistBinning','DistMean'});
% DistBins=(1:1:200).'; DistBins(:,2)=DistBins(:,1)+1;
% DistBins(:,3)=7;DistBins(:,4)=mean(DistBins(:,1:2),2);
% DistBins=array2table(DistBins,'VariableNames',{'DistMin','DistMax','DistBinning','DistMean'});



for Mouse=1:size(MouseInfo,1)
    for TimeBin=1:size(TimeBins,1)
        MouseId=MouseInfo.MouseId(Mouse);
        Selection=MouseInfoTime(MouseInfoTime.MouseId==MouseId...
            & MouseInfoTime.Time2Treatment>TimeBins.TimeMin(TimeBin)...
            & MouseInfoTime.Time2Treatment<=TimeBins.TimeMax(TimeBin),:);
        Wave1=nanmean(Selection.Volume1,1).';
        Wave1=Wave1/sum(Wave1(:));
        AxisFraction(DistBins.DistMin,TimeBin,Mouse)=Wave1(DistBins.DistMin);
    end
end
Groups={[314;336;341;353;375],{'Vehicle'};[318;331;346;347;371],{'NB-360'}};
Groups=array2table(Groups,'VariableNames',{'MouseIds','Description'});
clear Selection;
for Group=1:size(Groups,1)
    MouseIds=Groups.MouseIds{Group,1};
    Mice=find(ismember(MouseInfo.MouseId,MouseIds)==1);
    Selection{Group,1}=nanmean(AxisFraction(:,:,Mice),3);
end
Path2file=[W.G.PathOut,'\VolumeDistribution\Version3'];
finalEvaluation_VolumeDistribution_Plot(TimeBins.TimeMean,DistBins.DistMean-50,Selection,{[0.5;0.5;0.5];[0;0;0]},Path2file);
keyboard;

