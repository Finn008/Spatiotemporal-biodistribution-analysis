function [MouseInfo]=finalEvaluation_PlaqueGrowth(MouseInfo,TraceStacks)
Timer=datenum(now);
global W;
% keyboard;
for iStack=1:size(TraceStacks,1)
    Mouse=find(MouseInfo.MouseId==TraceStacks.MouseId(iStack));
    Roi=find(MouseInfo.RoiInfo{Mouse}.Roi==TraceStacks.Roi(iStack));
    % % %     TimeAxis=MouseInfo.RoiInfo{Mouse}.Files{Roi}.Age;
    % % %     StartTreatment=MouseInfo.StartTreatmentNum{Mouse};
    % % %     if StartTreatment==0
    % % %         TimeSections=[min(TimeAxis(:)),max(TimeAxis(:))+0.0001];
    % % %     else
    % % %         TimeSections=[min(TimeAxis(:)),StartTreatment];
    % % %         TimeSections(2,1:2)=[StartTreatment,max(TimeAxis(:))];
    % % %     end
    
    PlaqueData=TraceStacks.Data{iStack,1};
    % % %     PlaqueNumber=size(PlaqueData,1);
    
    % % %     for Pl=1:PlaqueNumber
    % % %         Table=table;
    % % %         Table.Radius=PlaqueData.Data{Pl}.Radius;
    % % %         Table.BorderTouch=PlaqueData.Data{Pl}.BorderTouch;
    % % %         Table.Out(Table.Radius==0|Table.BorderTouch~=0,1)=1;
    % % %
    % % %         Table.Age=TimeAxis(1:size(Table,1));
    % % %         for m=1:size(TimeSections,1)
    % % %             Wave1=Table(Table.Age>=TimeSections(m,1) & Table.Age<TimeSections(m,2) & Table.Out==0,:);
    % % %             PlaqueData.Timepoints(Pl,m)=size(Wave1,1);
    % % %             if size(Wave1,1)<3
    % % %                 continue;
    % % %             elseif size(Wave1,1)==2
    % % %                 RobustOpts='off';
    % % %             elseif size(Wave1,1)>2
    % % %                 RobustOpts='on';
    % % %             end
    % % %             Curve=fitlm(Wave1.Age,Wave1.Radius,'RobustOpts',RobustOpts);
    % % %             PlaqueData.UmPerWeek(Pl,m)=Curve.Coefficients{'x1','Estimate'}*7;
    % % %             PlaqueData.RMSE(Pl,m)=Curve.RMSE;
    % % %             PlaqueData.Intercept(Pl,m)=Curve.Coefficients{'(Intercept)','Estimate'};
    % % %
    % % %             Wave2=table(TimeSections(m,:).','VariableNames',{'Age'});
    % % %             Wave2.Radius=Wave2.Age.*PlaqueData.UmPerWeek(Pl,m)/7+PlaqueData.Intercept(Pl,m);
    % % %             PlaqueData.FitLines(Pl,m)={Wave2};
    % % %         end
    % % %     end
    
    % % %     for m=1:size(TimeSections,1)
    % % %         try
    % % %             Wave1=PlaqueData(PlaqueData.Timepoints(:,m)>2 & PlaqueData.RMSE(:,m)<1,:);
    % % %             MeanGrowth(m,1)=mean(Wave1.UmPerWeek(:,m));
    % % %         catch % if only two timepoints and/or RMSE not available
    % % %             MeanGrowth(m,1)=nan;
    % % %         end
    % % %     end
    % % %     MouseInfo.RoiInfo{Mouse}.PlaqueNumber(Roi,1)=PlaqueNumber;
    MouseInfo.RoiInfo{Mouse}.TraceData(Roi,1)={PlaqueData};
    % % %     MouseInfo.RoiInfo{Mouse}.MeanGrowth(Roi,1:size(MeanGrowth,1))=MeanGrowth.';
end

% % % %% pool Rois of each mouse
% % % for Mouse=1:size(MouseInfo,1)
% % %     try
% % %         Wave1=MouseInfo.RoiInfo{Mouse}.TraceData;
% % %         Wave1=Wave1(cellfun(@istable,Wave1),:);
% % %         PlaqueData=Wave1{1};
% % %
% % %         for m=2:size(Wave1,1)
% % %             try
% % %                 PlaqueData=[PlaqueData;Wave1{m}];
% % %             end
% % %         end
% % %     catch
% % %         continue;
% % %     end
% % %
% % %     for m=1:size(PlaqueData.UmPerWeek,2)
% % %         Wave1=PlaqueData.UmPerWeek(PlaqueData.Timepoints(:,m)>2 & PlaqueData.RMSE(:,m)<1,m);
% % %         MouseInfo.MeanGrowth(Mouse,m)=mean(Wave1);
% % %         MouseInfo.PlaqueNumber4MeanGrowth(Mouse,m)=size(Wave1,1);
% % %     end
% % % end
disp(['finalEvaluation_PlaqueGrowth: ',num2str(round((datenum(now)-Timer)*24*60)),'min']);