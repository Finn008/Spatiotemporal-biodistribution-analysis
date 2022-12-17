function [MouseInfo]=finalEvaluationPoolRois(MouseInfo)
keyboard; % integrated into finalEvaluation_PlaquesQuantificationGlobal_2
tic;
%% pool Rois of each mouse
for Mouse=1:size(MouseInfo,1)
    try
        AllRoiInfo=MouseInfo.RoiInfo{Mouse}.TraceData;
        AllRoiInfo=AllRoiInfo(cellfun(@istable,AllRoiInfo),:);
        TotalVolume=0;
        for Roi=1:size(AllRoiInfo,1)
            
            try
                if Roi==1
                    PlaqueData=AllRoiInfo{1};
                else
                    
                    PlaqueData=[PlaqueData;AllRoiInfo{Roi}];
                end
                Fileinfo=getFileinfo_2(['X156_M',num2str(MouseInfo.MouseId(Mouse)),'_',MouseInfo.RoiInfo{Mouse}.StackB{Roi},'_Trace.ims']); 
                Volume=prod(Fileinfo.Um{1})/1000000000;
                TotalVolume=TotalVolume+Volume;
                
                % BabyPlaques
                MouseInfo.RoiInfo{Mouse,1}.Volume(Roi,1)=Volume;
                TimeDuration=MouseInfo.RoiInfo{Mouse}.Files{Roi}.Age;
                if MouseInfo.StartTreatmentNum(Mouse)==0
                    Wave1=size(find(isnan(AllRoiInfo{Roi}.PlBirth)==0),1);
                    TimeDuration=[TimeDuration(end)-TimeDuration(1)];
                else
                    Wave1=size(find(PlaqueData.PlBirth<=MouseInfo.StartTreatmentNum(Mouse)),1);
                    Wave1(1,2)=size(find(PlaqueData.PlBirth>MouseInfo.StartTreatmentNum(Mouse)),1);
                    TimeDuration=[MouseInfo.StartTreatmentNum(Mouse)-TimeDuration(1),TimeDuration(end)-MouseInfo.StartTreatmentNum(Mouse)];
                end
                
                MouseInfo.RoiInfo{Mouse}.BabyPlaques(Roi,1:size(Wave1,2))=Wave1./(TimeDuration/7)/Volume;
            end
        end
    catch
        continue;
    end
    %  compare growth before with during treatment
    for m=1:size(PlaqueData.PlRadPerWeek,2)
        try
            Wave1=PlaqueData.PlRadPerWeek(PlaqueData.Timepoints(:,m)>2,m); % & PlaqueData.RMSE(:,m)<1
            MouseInfo.MeanPlGrowth(Mouse,m)=mean(Wave1);
        end
        % % % %         MouseInfo.PlaqueNumber4MeanPlGrowth(Mouse,m)=size(Wave1,1);
        try
            Wave1=PlaqueData.Dys1VolPerWeek(PlaqueData.Timepoints(:,m)>2,m); % & PlaqueData.RMSE(:,m)<1
            MouseInfo.MeanDys1VolGrowth(Mouse,m)=mean(Wave1);
        end
    end
    % BabyPlaques
    MouseInfo.TotalVolume(Mouse,1)=TotalVolume;
    try
        Wave1=nanmean(MouseInfo.RoiInfo{Mouse}.BabyPlaques,1);
        MouseInfo.BabyPlaques(Mouse,1:size(Wave1,2))=Wave1;
    end
    
    % single growth per week
    Table=table;
    for Pl=1:size(PlaqueData,1)
%         Age=MouseInfo.RoiInfo{Mouse}.Files{1}.Age;
        Age=PlaqueData.Data{Pl}.Age;
        Growth=PlaqueData.Data{Pl}.Growth;
        Radius=PlaqueData.Data{Pl}.Radius;
        Plaque=repmat(Pl,[size(Age,1),1]);
        Table2add=table(Plaque,Age,Radius,Growth,'VariableNames',{'Plaque','Age','Radius','Growth'});
        Table=[Table;Table2add];
    end
    MouseInfo.PlaqueContainer(Mouse,1)={struct('PlaqueGrowth',Table)};
end

return;
%% calculate mean growth
clear MeanGrowth;
for m=1:size(TimeSections,1)
    try
        Wave1=DataOut(DataOut.Timepoints(:,m)>2 & DataOut.RMSE(:,m)<1,:);
        MeanGrowth(m,1)=mean(Wave1.Growth(:,m));
    catch % if only two timepoints and/or RMSE not available
        MeanGrowth(m,1)=nan;
    end
end

MouseInfo.RoiInfo{Mouse}.PlMeanGrowth(Roi,1:size(MeanGrowth,1))=MeanGrowth.';
disp(['finalEvaluationPoolRois: ',num2str(round(toc/60)),'min']);