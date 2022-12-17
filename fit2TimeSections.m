function [DataOut]=fit2TimeSections(TimeSections,Table)

DataOut=table;
for m=1:size(TimeSections,1)
    Wave1=Table(Table.Age>=TimeSections(m,1) & Table.Age<=TimeSections(m,2) & Table.Out==0 & isnan(Table.Values)==0,:);
    DataOut.Timepoints(1,m)=size(Wave1,1);
    if size(Wave1,1)<3
        DataOut.Growth(1,m)=nan;
        DataOut.RMSE(1,m)=nan;
        DataOut.Intercept(1,m)=nan;
        DataOut.FitLines(1,m)={table};
        continue;
    elseif size(Wave1,1)==2
        RobustOpts='off';
    elseif size(Wave1,1)>2
        RobustOpts='on';
    end
    Curve=fitlm(Wave1.Age,Wave1.Values,'RobustOpts',RobustOpts);
    DataOut.Growth(1,m)=Curve.Coefficients{'x1','Estimate'}*7;
    DataOut.RMSE(1,m)=Curve.RMSE;
    DataOut.Intercept(1,m)=Curve.Coefficients{'(Intercept)','Estimate'};
    
    Wave2=table(TimeSections(m,:).','VariableNames',{'Age'});
    Wave2.Radius=Wave2.Age.*DataOut.Growth(1,m)/7+DataOut.Intercept(1,m);
    DataOut.FitLines(1,m)={Wave2};
end


