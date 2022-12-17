function [MouseInfo]=finalEvaluation_Quantification2(MouseInfo)

for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    RoiInfo=MouseInfo.RoiInfo{Mouse,1};
    for Roi=1:size(RoiInfo,1)
        RoiId=RoiInfo.Roi(Roi);
        PlaqueList=[];
        try; PlaqueList=RoiInfo.TraceData{Roi,1}; end;
        if isempty(PlaqueList)
            continue;
        end
        
        TimeAxis=RoiInfo.Files{Roi}.Age;
        StartTreatment=MouseInfo.StartTreatmentNum{Mouse};
        if StartTreatment==0
            TimeSections=[min(TimeAxis(:)),max(TimeAxis(:))+0.0001];
        else
            TimeSections=[min(TimeAxis(:)),StartTreatment];
            TimeSections(2,1:2)=[StartTreatment,max(TimeAxis(:))];
        end
        
        
        PlaqueNumber=size(PlaqueList.Data,1);
        MouseInfo.RoiInfo{Mouse}.PlaqueNumber(Roi,1)=PlaqueNumber;
        %% Plaques and Dystrophies1
%         for Mod={'Plaques','Dystrophies1'}
        for Mod={'Dystrophies1'}
            DataOut=table;
            for Pl=1:PlaqueNumber
                PlaqueData=PlaqueList.Data{Pl,1};
                Table=table;
                Table.BorderTouch=PlaqueData.BorderTouch;
                Table.Age=TimeAxis(1:size(Table,1));
                if strcmp(Mod{1},'Plaques')
                    Table.Values=PlaqueData.Radius;
                    Table.Out(Table.Values==0|Table.BorderTouch~=0,1)=1;
                elseif strcmp(Mod{1},'Dystrophies1')
                    try
                        Table.Values=PlaqueData.Dystrophy1Volume;
                    catch
                        break;
                    end
                    Table.Out(1)=0;
                end
                
                for m=1:size(TimeSections,1)
                    Wave1=Table(Table.Age>=TimeSections(m,1) & Table.Age<TimeSections(m,2) & Table.Out==0 & isnan(Table.Values)==0,:);
                    DataOut.Timepoints(Pl,m)=size(Wave1,1);
                    if size(Wave1,1)<3
                        DataOut.Growth(Pl,m)=nan;
                        DataOut.RMSE(Pl,m)=nan;
                        DataOut.Intercept(Pl,m)=nan;
                        DataOut.FitLines(Pl,m)={table};
                        continue;
                    elseif size(Wave1,1)==2
                        RobustOpts='off';
                    elseif size(Wave1,1)>2
                        RobustOpts='on';
                    end
                    Curve=fitlm(Wave1.Age,Wave1.Values,'RobustOpts',RobustOpts);
                    DataOut.Growth(Pl,m)=Curve.Coefficients{'x1','Estimate'}*7;
                    DataOut.RMSE(Pl,m)=Curve.RMSE;
                    DataOut.Intercept(Pl,m)=Curve.Coefficients{'(Intercept)','Estimate'};
                    
                    Wave2=table(TimeSections(m,:).','VariableNames',{'Age'});
                    Wave2.Radius=Wave2.Age.*DataOut.Growth(Pl,m)/7+DataOut.Intercept(Pl,m);
                    DataOut.FitLines(Pl,m)={Wave2};
                end
            end
            if isempty(DataOut)
                continue;
            end
            clear MeanGrowth;
            for m=1:size(TimeSections,1)
                try
                    Wave1=DataOut(DataOut.Timepoints(:,m)>2 & DataOut.RMSE(:,m)<1,:);
                    MeanGrowth(m,1)=mean(Wave1.Growth(:,m));
                catch % if only two timepoints and/or RMSE not available
                    MeanGrowth(m,1)=nan;
                end
            end
            
            if strcmp(Mod{1},'Plaques')
                PlaqueList.Timepoints=DataOut.Timepoints;
                PlaqueList.PlRadPerWeek=DataOut.Growth;
                PlaqueList.PlFitLines=DataOut.FitLines;
                MouseInfo.RoiInfo{Mouse}.PlMeanGrowth(Roi,1:size(MeanGrowth,1))=MeanGrowth.';
            elseif strcmp(Mod{1},'Dystrophies1')
                PlaqueList.Dys1VolPerWeek=DataOut.Growth;
                PlaqueList.Dys1FitLines=DataOut.FitLines;
                MouseInfo.RoiInfo{Mouse}.Dys1MeanGrowth(Roi,1:size(MeanGrowth,1))=MeanGrowth.';
            end
        end
        MouseInfo.RoiInfo{Mouse}.TraceData{Roi,1}=PlaqueList;
    end
end

