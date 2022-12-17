function finalEvaluation_VisualizePathologyPercentage(MouseInfo,MouseInfoTime)



TimeMinMax=[min(MouseInfoTime.Time2Treatment);max(MouseInfoTime.Time2Treatment)];
TimeBinning=[7];
TimeBins=zeros(0,3);
for TimeBin=1:size(TimeBinning,1)
    Wave1=ceil(TimeMinMax(2)/TimeBinning(TimeBin))*TimeBinning(TimeBin);
    Wave2=floor(TimeMinMax(1)/TimeBinning(TimeBin))*TimeBinning(TimeBin);
    Wave1=(Wave2:TimeBinning(TimeBin):Wave1).';
    TimeBins=[TimeBins;[Wave1(1:end-1),Wave1(2:end),repmat(TimeBinning(TimeBin),[size(Wave1,1)-1,1])]];
end
TimeBins=array2table(TimeBins,'VariableNames',{'TimeMin','TimeMax','TimeBin'});

VariableNames={'DeadPercentage';'PlaquePercentage';'DystrophicPercentage';'BoutonDevoidPercentage'};

BinTable=table;
for Bin=1:size(VariableNames,1)
    Wave1=TimeBins;Wave1.Var(:,1)=VariableNames(Bin);
    BinTable=[BinTable;Wave1];
end

% % % MouseExclude=struct;
% % % MouseExclude.DeadPercentage=[314];
% % % MouseExclude.PlaquePercentage=[314];
% % % MouseExclude.DystrophicPercentage=[314];

Table=table;
for Bin=1:size(BinTable,1)
    RowId=[BinTable.Var{Bin},'_Time',num2str(BinTable.TimeMin(Bin)),'to',num2str(BinTable.TimeMax(Bin))];
    for Mouse=1:size(MouseInfo,1)
        if Mouse==1
            Table(RowId,BinTable.Properties.VariableNames)=BinTable(Bin,:);
        end
        Selection=MouseInfoTime(MouseInfoTime.Mouse==Mouse & MouseInfoTime.Time2Treatment>BinTable.TimeMin(Bin) & MouseInfoTime.Time2Treatment<=BinTable.TimeMax(Bin),:);
        if size(Selection,1)==0
            Data=NaN;
        else
            Data=mean(Selection{:,BinTable.Var{Bin}});
        end
        Table(RowId,['M',num2str(MouseInfo.MouseId(Mouse))])={Data};
        
    end

    continue;
    NanRows=nansum(Table,2)==0;
    Table=Table(NanRows==0,:);
    AgeAxis=AgeAxis(NanRows==0);
    
    ExcelList=repmat(VarId,[1,size(MouseInfo,1)+1]);
    ExcelList(2,:)=[{'MouseId'},num2cell(MouseInfo.MouseId.')];
    ExcelList(3,:)=[{'TreatmentType'},MouseInfo.TreatmentType.'];
    Wave1=[num2cell(AgeAxis),num2cell(Table)];
    ExcelList=[ExcelList;Wave1];
    
    xlsActxWrite(ExcelList,Workbook,VarId{1},[],1);
    
    Xspline=(AgeAxis(1):1/365:AgeAxis(end)).';
    
    if Var==1
        MouseSpline=[{[];'Age'};num2cell(Xspline)];
        MouseMean=[{[];'Age'};num2cell(AgeAxis)];
    end
    
    TreatmentTypes={'NB360Vehicle';'NB360'};
    for Type=1:2
        TypeId=TreatmentTypes(Type);
        Ind=strfind1(MouseInfo.TreatmentType,TypeId);
        try
            Exclude=find(ismember(MouseInfo.MouseId,MouseExclude.(VarId{1})));
            Ind(ismember(Ind,Exclude),:)=[];
        end
        
        Y=Table(:,Ind);
        X=repmat(AgeAxis,[size(Y,2),1]);
        Y=reshape(Y,prod(size(Y)),1);
        Fit=fit(X,Y,'smoothingspline','Exclude',isnan(Y),'SmoothingParam',0.5);
        Wave1=feval(Fit,Xspline);
        MouseSpline(:,size(MouseSpline,2)+1)=[TypeId;VarId;num2cell(Wave1)];
        IndTreat={find(X<=4),find(AgeAxis<=4);find(X>=4),find(AgeAxis>=4)};
        clear Wave1;
        for m=1:2
            Fit=fitlm(X(IndTreat{m,1}),Y(IndTreat{m,1}),'Exclude',isnan(Y(IndTreat{m,1})));
            Wave1(IndTreat{m,2},1)=feval(Fit,AgeAxis(IndTreat{m,2}));
        end
        MouseMean(:,size(MouseMean,2)+1)=[TypeId;VarId;num2cell(Wave1)];
        
        
        
    end
end

PathExcelExport='\\GNP90N\share\Finn\Raw data\PathologyPercentage_6.xlsx';
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(Table,Workbook,'PathologyPercentage',[],'DeleteOnlyContent');
Workbook.Save;
Workbook.Close;
