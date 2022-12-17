function [MouseData,FileData,TreatmentData]=neuronalActivity_FrequencyData(DataType,MouseData,Path2Folder)

FileData=table;
for Mouse=1:size(MouseData,1)
    try
        MouseId=MouseData.MouseId(Mouse);
        Path2file=[Path2Folder,'\',num2str(MouseId),'.xlsx'];
        [~,~,Data]= xlsread(Path2file,DataType);
        RowNumber=size(Data,1);
        Wave1=cell2mat(Data(:,4:end));
        Wave1=[Wave1,nan(RowNumber,9-size(Wave1,2))];
        
        
        Wave1=table(repmat(MouseId,[RowNumber,1]),Data(:,1),repmat(DataType,[RowNumber,1]),Data(:,3),Wave1,'VariableNames',{'Mouse','Area','Type','NeuronTangle','Data'});
        
        FileData=[FileData;Wave1];
        
    catch Error
        MouseData.Error(Mouse,1)={Error};
    end
end

for m=1:size(FileData,1)
    Wave1=find(isnan(FileData.Data(m,:))==0).';
    FileData.TpCount(m,1)=size(Wave1,1);
end

FileData.StdDev=nanstd(FileData.Data,[],2);
FileData.Mean=nanmean(FileData.Data,2);




% Slope
FileData.Slope=nan(size(FileData,1),1);
for Neuron=find(FileData.TpCount>=6).'
    Data=FileData.Data(Neuron,:);
    Mouse=find(MouseData.Mouse==FileData.Mouse(Neuron));
    Time=MouseData.IT(Mouse,:);
    F = fittype('A1*x+A2','independent','x');
    [Fit,Gof] = fit(Time.',Data.',F,'Exclude',isnan(Data));
    Coef=coeffvalues(Fit);
    FileData.Slope(Neuron,1)=Coef(1);
end

%  each mouse
MouseData=sortrows(MouseData,'TreatmentType');
MouseData.MeanTpNeuron=nan(size(MouseData,1),60);
MouseData.MeanTpTangle=nan(size(MouseData,1),60);
% MeanTp=table;
for Mouse=1:size(MouseData,1)
    MouseId=MouseData.Mouse(Mouse);
    Ind=find(FileData.Mouse==MouseId & FileData.TpCount>3);
    
    MouseData.Mean(Mouse,1)=nanmean(FileData.Mean(Ind));
    MouseData.StdDev(Mouse,1)=nanmean(FileData.StdDev(Ind));
    
    MouseData.NeuronCount3(Mouse,1)=size(Ind,1);
    Wave1=find(FileData.Mouse==MouseId & FileData.TpCount>=6);
    MouseData.NeuronCount6(Mouse,1)=size(Wave1,1);
    
    MouseData.Slope(Mouse,1)=nanmean(FileData.Slope(FileData.Mouse==MouseId));
    
    
    if strcmp(MouseData.TreatmentType(Mouse),'P301SHOTS');
        Ind1=find(FileData.Mouse==MouseId & FileData.TpCount>3 & strcmp(FileData.NeuronTangle,'Neuron'));
        Ind2=find(FileData.Mouse==MouseId & FileData.TpCount>3 & strcmp(FileData.NeuronTangle,'Tangle'));
        MouseData.MeanTangle(Mouse,1:2)=[nanmean(FileData.Mean(Ind1)),nanmean(FileData.Mean(Ind2))];
        MouseData.StdDevTangle(Mouse,1:2)=[nanmean(FileData.StdDev(Ind1)),nanmean(FileData.StdDev(Ind2))];
    end
    
    NeuronTangle={'Neuron';'Tangle'};
    for NeuronType=1:2
        NeuronTypeId=NeuronTangle{NeuronType};
        Ind=find(FileData.Mouse==MouseId & strcmp(FileData.NeuronTangle,NeuronTypeId));
        if Ind==0
        else
            Wave1=nanmean(FileData.Data(Ind,:),1);
            MouseData.MeanTp(Mouse,NeuronType)={Wave1};
            Timepoints=MouseData.IT(Mouse,:).';
            Wave1(isnan(Timepoints))=[];
            Timepoints(isnan(Timepoints))=[];
            MouseData{Mouse,{['MeanTp',NeuronTypeId]}}(Timepoints)=Wave1;
        end
    end
end

% each TreatmentType
TreatmentCategories=unique(MouseData.TreatmentType);
TreatmentData=table(TreatmentCategories,'VariableNames',{'Cat'});
for Cat=1:size(TreatmentCategories,1)
    CatId=TreatmentCategories{Cat};
    Ind=strfind1(MouseData.TreatmentType,CatId);
    Parameters={'Mean';'StdDev';'MeanTangle';'StdDevTangle';'Slope'};
    for Param=1:size(Parameters,1)
        ParamId=Parameters{Param};
        TreatmentData(Cat,ParamId)={nanmean(table2array(MouseData(Ind,ParamId)),1)};
    end
end

%% export data into excel sheets
OutputPath=[Path2Folder,'\Results\',DataType,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(OutputPath);
% MouseData
VariableNames=MouseData.Properties.VariableNames.';
for m=1:size(VariableNames,1)
    VarCols(m,1)=size(MouseData{:,VariableNames(m)},2);
end
Table=MouseData(:,VariableNames(VarCols<10));

xlsActxWrite(Table,Workbook,['MouseGeneral'],[],1);

LargeTables=find(VarCols>=10);

for m=1:size(LargeTables,1)
    Var=VariableNames{LargeTables(m)};
    Table=MouseData(:,Var);
    xlsActxWrite(Table,Workbook,['Mouse',Var],[],1);
end

xlsActxWrite(TreatmentData,Workbook,['GroupData'],[],1);

xlsActxWrite(FileData,Workbook,['FileData'],[],1);
Workbook.Save;
Workbook.Close;
% keyboard; %save and quit


return;

%% display frequency trace of all mice in one image
Path2Output=[Path2Folder,'\Output\'];

for Mouse=1:size(MouseData,1)
    MouseId=MouseData.Mouse(Mouse);
    Ind=find(FileData.Mouse==MouseId & isnan(FileData.Slope)==0);
    Xaxis=(0:20).';
    Wave1=repmat(Xaxis.',[size(Ind,1),1]);
    Wave2=repmat(FileData.Slope(Ind),[1,size(Xaxis,1)]);
    Data=Wave1.*Wave2;
    MeanSlope=mean(Data,1);
    
    J=struct;
    J.X=Xaxis;
    J.OrigYaxis=[...
        {Data},{struct('Color',{{[0.5,0.5,0.5]}},'LineType','-','LineWidth',1)};...
        {MeanSlope},{struct('Color',{{'r'}},'LineType','-','LineWidth',3)}];
    J.Xlab='Time [d]';
    J.Ylab='Frequency [1/min]';
    J.Xrange=[0;20];
    J.Yrange=[-5;5];
    J.Style=1;
    J.Path2file=[Path2Output,'Frequency_',num2str(MouseId),'.jpg'];
    
    movieBuilder_5(J);
end

Xaxis=(0:20).';
Y=table;
Y.LineType=repmat('-',[size(MouseData,1),1]);
for Mouse=1:size(MouseData,1)
    MouseId=MouseData.Mouse(Mouse);
    if strcmp(MouseData.TreatmentType{Mouse},'Bl6B')
        Y.Color(Mouse,1)={'w'};
    elseif strcmp(MouseData.TreatmentType{Mouse},'Bl6TS')
        Y.Color(Mouse,1)={'c'};
    elseif strcmp(MouseData.TreatmentType{Mouse},'P301SHOB')
        Y.Color(Mouse,1)={'r'};
    elseif strcmp(MouseData.TreatmentType{Mouse},'P301SHOTS')
        Y.Color(Mouse,1)={'y'};
    end
    Y.Data(Mouse,1:size(Xaxis,1))=MouseData.Slope(Mouse).*Xaxis;
end


J=struct;
J.X=Xaxis;
% J.OrigYaxis=[...
%     {Data},{struct('Color',{{[0.5,0.5,0.5]}},'LineType','-','LineWidth',1)};...
%     {MeanSlope},{struct('Color',{{'r'}},'LineType','-','LineWidth',3)}];
J.Y=Y;
J.Xlab='Time [d]';
J.Ylab='Frequency [1/min]';
J.Xrange=[0;20];
J.Yrange=[-2;2];
J.Style=1;
J.Path2file=[Path2Output,'FrequencyAll.jpg'];
% J.Legend=TreatmentCategories;
movieBuilder_5(J);