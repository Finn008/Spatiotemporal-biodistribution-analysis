function [TreatmentGroups]=finalEvaluation_PoolTreatmentTypes(MouseInfoTime,MouseInfo)
keyboard;
TreatmentGroups=table;
TreatmentGroups.TreatmentType=unique(MouseInfo.TreatmentType);

AgeAxis=(0:7:365).'/(365/12);

VariableNames={'DeadPercentage';'PlaquePercentage';'DystrophicPercentage';'BoutonDevoidPercentage'};

for Var=1:size(VariableNames,1)
    VarId=VariableNames(Var);
    
    Table=nan(size(AgeAxis,1),size(MouseInfo,1));
    for Mouse=1:size(MouseInfo,1)
        Selection=MouseInfoTime(MouseInfoTime.Mouse==Mouse,:);
        for Time=1:size(Selection,1)
            Ind=find(AgeAxis>Selection.Age(Time)/(365/12),1);
            Table(Ind,Mouse)=Selection{Time,VarId};
        end
    end
    NanRows=nansum(Table,2)==0;
    Table=Table(NanRows==0,:);
    AgeAxis=AgeAxis(NanRows==0);
    
    TreatmentTypes={'NB360Vehicle','NB360'};
    for Type=1:2
        TypeId=TreatmentTypes(Type);
        Ind=strfind1(MouseInfo.TreatmentType,TypeId);
        %     Fit=fit(AgeAxis,Table(:,Ind),'linearinterp');
        Y=nanmean(Table(:,Ind),2);
        Weight=sum(isnan(Table(:,Ind))==0,2);
        Fit=fit(AgeAxis,Y,'smoothingspline','Exclude',isnan(Y),'Weight',Weight,'SmoothingParam',0.5);
        Wave1=feval(Fit,AgeAxis);
        TreatmentGroups(Type,VarId)=1;
    end
    plot(Fit,AgeAxis,Y);
end