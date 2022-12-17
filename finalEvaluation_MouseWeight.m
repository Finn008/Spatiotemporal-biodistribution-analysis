function finalEvaluation_MouseWeight()

global W;

F2=W.G.T.F2{W.Task};
F2Info=table;
[F2Info.Mouse,Wave2]=unique(F2.Mouse,'stable');
F2Info(:,{'BirthDate','StartTreatment','Dead','TreatmentType'})=F2(Wave2,{'BirthDate','StartTreatment','Dead','TreatmentType'});

Path2InputData=['\\Gnp42n\marvin\Finn\aktuelle Dokumente\BACE food.xlsx'];
[~,~,BaceFood]= xlsread(Path2InputData,'Matlab');

% VariableNames=BaceFood(1,:);
% VariableNames(cellfun(@isnumeric,VariableNames))=num2strArray_3(VariableNames(cellfun(@isnumeric,VariableNames)));

BaceFood=array2table(BaceFood(2:end,:),'VariableNames',BaceFood(1,:));
BaceFood.MouseId=cell2mat(BaceFood.MouseId);
% Wave2=[BaceFood(2:end,1),BaceFood(2:end,4:end)];

MouseInfo=table;

MouseInfo.MouseId=unique(BaceFood.MouseId);
for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    Ind=find(BaceFood.MouseId==MouseId & strcmp(BaceFood.Notes1,'Birth'));
    Birthdate=BaceFood.Notes2(Ind);
    BirthdateNum=datenum(Birthdate,'dd.mm.yyyy');
    MouseInfo.Birthdate(Mouse,1)=Birthdate;
    
    Ind=find(BaceFood.MouseId==MouseId & strcmp(BaceFood.Notes1,'StartTreatment'));
    MouseInfo.StartTreatment(Mouse,1)=BaceFood.Notes2(Ind);
    
    Ind=find(BaceFood.MouseId==MouseId & strcmp(BaceFood.Notes1,'TreatmentType'));
    MouseInfo.TreatmentType(Mouse,1)=BaceFood.Notes2(Ind);
    
    for Time=1:20
        Col=['T',num2str(Time)];
        % Date
        Ind=find(BaceFood.MouseId==MouseId & strcmp(BaceFood.Type,'Date'));
        Date=BaceFood{Ind,Col};
        try
            DateNum=datenum(Date,'dd.mm.yyyy');
        catch
            continue;
        end
        
        % MouseWeight
        Ind=find(BaceFood.MouseId==MouseId & strcmp(BaceFood.Type,'MouseWeight'));
        MouseWeight=BaceFood{Ind,Col}{1};
        
        % Food
        Ind=find(BaceFood.MouseId==MouseId & strcmp(BaceFood.Type,'Food'));
        Food=BaceFood{Ind,Col}{1};
        
        % AddFood
        Ind=find(BaceFood.MouseId==MouseId & strcmp(BaceFood.Type,'AddFood'));
        AddFood=BaceFood{Ind,Col}{1};
        
        AgeWeek=round((DateNum-BirthdateNum)/7);
        MouseInfo.WeightWeek(Mouse,AgeWeek)=MouseWeight;
    end
    
    % compare with F2Info
    MouseF2=find(F2Info.Mouse==MouseId);
    if strcmp(F2Info.TreatmentType(MouseF2),MouseInfo.TreatmentType(Mouse))~=1
        keyboard;
    end
    if datenum(F2Info.BirthDate{MouseF2}(2:end),'yyyy.mm.dd')~=datenum(MouseInfo.Birthdate{Mouse},'dd.mm.yyyy')
        keyboard;
    end 
    if datenum(F2Info.StartTreatment{MouseF2}(2:end),'yyyy.mm.dd')~=datenum(MouseInfo.StartTreatment{Mouse},'dd.mm.yyyy')
        keyboard;
    end 
    
end

MouseInfo.WeightWeek(MouseInfo.WeightWeek==0)=NaN;

PathExcelExport='\\GNP90N\share\Finn\Raw data\MouseWeight.xlsx';
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(MouseInfo,Workbook,['MouseWeight'],[],1);
Workbook.Save;
Workbook.Close;

keyboard;