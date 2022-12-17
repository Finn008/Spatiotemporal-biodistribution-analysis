function neuronalActivity_FrequencyData(DataType,MouseInfo,Path2Folder)

MouseInfo=sortrows(MouseInfo,'TreatmentType');
Table=table;
% Table.Specification(1)={'MouseId'};Table.Data=MouseInfo.Mouse.';
% MouseTable=addData2OutputTable(MouseTable,MouseInfo.Mouse.',struct('Str1','Mouse'),[1:size(MouseInfo,1)])

% MouseInfo
NumberOfTimepoints=size(MouseInfo.IT,2);

FileData=table;
for Mouse=1:size(MouseInfo,1)
    try
        MouseId=MouseInfo.MouseId(Mouse);
        Path2file=[Path2Folder,'\',num2str(MouseId),'.xlsx'];
        [~,~,Data]= xlsread(Path2file,DataType);
        RowNumber=size(Data,1);
        Data2add=cell2mat(Data(:,4:end));
        Data2add=[Data2add,nan(RowNumber,NumberOfTimepoints-size(Data2add,2))];
        
        Data2add=table(repmat(MouseId,[RowNumber,1]),Data(:,1),repmat(DataType,[RowNumber,1]),Data(:,3),Data2add,'VariableNames',{'Mouse','Area','Type','NeuronTangle','Data'});
        Data2add.TpCount=sum(isnan(Data2add.Data)==0,2);
        Data2add(Data2add.TpCount<MouseInfo.Timepoints(Mouse)-1,:)=[];
        
        FileData=[FileData;Data2add];
        
    catch Error
        MouseInfo.Error(Mouse,1)={Error};
    end
end

% for m=1:size(FileData,1)
%     Wave1=find(isnan(FileData.Data(m,:))==0).';
%     FileData.TpCount(m,1)=size(Wave1,1);
% end

FileData.StdDev=nanstd(FileData.Data,[],2);
FileData.StdDev5=FileData.StdDev;
FileData.StdDev5(FileData.TpCount<5)=NaN;
FileData.Mean=nanmean(FileData.Data,2);
FileData.Mean3=FileData.Mean;
FileData.Mean3(FileData.TpCount<3)=NaN;

% Change
FileData.Change=nan(size(FileData,1),1);
for Neuron=find(FileData.TpCount>=3).'
    Data=FileData.Data(Neuron,:).';
    Data(isnan(Data),:)=[];
    Wave1=mean(abs(Data(2:end)-Data(1:end-1)));
    FileData.Change(Neuron,1)=Wave1;
end
FileData.ChangeTp=abs(FileData.Data(:,2:end)-FileData.Data(:,1:end-1));


% Slope
FileData.Slope=nan(size(FileData,1),1);

for Neuron=[] % find(FileData.TpCount>=6).'
    Data=FileData.Data(Neuron,:);
    Mouse=find(MouseInfo.MouseId==FileData.Mouse(Neuron));
    Time=MouseInfo.IT(Mouse,:);
    F = fittype('A1*x+A2','independent','x');
    [Fit,Gof] = fit(Time.',Data.',F,'Exclude',isnan(Data));
    Coef=coeffvalues(Fit);
    FileData.Slope(Neuron,1)=Coef(1);
end

%  each mouse

% MouseInfo.MeanTpNeuron=nan(size(MouseInfo,1),max(MouseInfo.IT(:)));
% MouseInfo.MeanTpTangle=nan(size(MouseInfo,1),max(MouseInfo.IT(:)));
for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    Selection1=FileData(find(FileData.Mouse==MouseId),:);
    
    NeuronTypes={'All';'Neuron';'Tangle'};
    for NeuronType=1:size(NeuronTypes,1)
        NeuronTypeId=NeuronTypes{NeuronType};
        if strcmp(NeuronTypeId,'All')
            Selection2=Selection1;
        else
            Selection2=Selection1(strcmp(Selection1.NeuronTangle,NeuronTypeId),:);
        end
        
        % FrequencyOverTime
        MeanFrequency=nanmean(Selection2.Data,1).';
        RowId=table;RowId.Timepoint=(1:size(MeanFrequency,1)).'; RowId.Specification(:,1)={'MeanFrequencyOverTime'}; RowId.NeuronType(:,1)={NeuronTypeId};
        Table=addData2OutputTable(Table,MeanFrequency,RowId,Mouse);
        
        % MedianOverTime
        MedianChange=nanmedian(Selection2.Data,1).';
        RowId=table;RowId.Timepoint=(1:size(MedianChange,1)).'; RowId.Specification(:,1)={'MedianFrequencyOverTime'}; RowId.NeuronType(:,1)={NeuronTypeId};
        Table=addData2OutputTable(Table,MedianChange,RowId,Mouse);
        
        % ChangeOverTime
        MeanChange=nanmean(Selection2.ChangeTp,1).';
        RowId=table;RowId.Timepoint=(2:size(MeanFrequency,1)).'; RowId.Specification(:,1)={'MeanChangeOverTime'}; RowId.NeuronType(:,1)={NeuronTypeId};
        Table=addData2OutputTable(Table,MeanChange,RowId,Mouse);
        
        if strfind1({'FrequencywithWhisking1min';'FrequencynoWhisking1min'},DataType,1)
            Edges1=(0:0.25:6).';
            Edges2=(0:0.25:3).';
        elseif strfind1({'Areanowhisking';'Areayeswhisking'},DataType,1)
            Edges1=(0:0.015:0.3).';
            Edges2=(0:0.008:0.16).';
        end
        
        % make Change distribution
        Wave1=histcounts(Selection2.Change,Edges1).';
        Wave1=Wave1/sum(Wave1)*100;
        RowId=table;RowId.FrMin=Edges1(1:end-1); RowId.FrMax=Edges1(2:end); RowId.Specification(:,1)={'ChangeHistogram'}; RowId.NeuronType(:,1)={NeuronTypeId};
        Table=addData2OutputTable(Table,Wave1,RowId,Mouse);
        
        % make frequency distribution
        Wave1=histcounts(Selection2.Mean3,Edges1).';
        Wave1=Wave1/sum(Wave1)*100;
        
        RowId=table;RowId.FrMin=Edges1(1:end-1); RowId.FrMax=Edges1(2:end); RowId.Specification(:,1)={'FrequencyHistogram'}; RowId.NeuronType(:,1)={NeuronTypeId};
        Table=addData2OutputTable(Table,Wave1,RowId,Mouse);
        
        Wave1=cumsum(Wave1);
        RowId=table;RowId.FrMin=Edges1(1:end-1); RowId.FrMax=Edges1(2:end); RowId.Specification(:,1)={'FrequencyCumSum'}; RowId.NeuronType(:,1)={NeuronTypeId};
        Table=addData2OutputTable(Table,Wave1,RowId,Mouse);
        
        % frequency distribution for each timepoint
        TimeBinning=(19.5:15:49.5).';
        for Tp=1:size(TimeBinning,1)-1
            Ind=find(MouseInfo.IT(Mouse,:)>=TimeBinning(Tp) & MouseInfo.IT(Mouse,:)<TimeBinning(Tp+1));
            if isempty(Ind)
                Wave1=nan(size(Edges1,1)-1,1);
            else
                Wave1=Selection2.Data(:,Ind);
                Wave1=histcounts(Wave1,Edges1).';
                Wave1=Wave1/sum(Wave1)*100;
                Wave1=cumsum(Wave1);
            end
            RowId=table;RowId.FrMin=Edges1(1:end-1); RowId.FrMax=Edges1(2:end); RowId.Specification(:,1)={'FrequencyCumSumOverTime'}; RowId.NeuronType(:,1)={NeuronTypeId}; RowId.TimeMin(:,1)=TimeBinning(Tp); RowId.TimeMax(:,1)=TimeBinning(Tp+1);
            Table=addData2OutputTable(Table,Wave1,RowId,Mouse);
            
            % Change
            Ind(Ind==1)=[]; Ind=Ind-1; % first change is allocated to the second timepoint
%%%%%%%%             Ind(Ind==NumberOfTimepoints)=[]; % first change is allocated to the latter timepoint
            Wave1=Selection2.ChangeTp(:,Ind);
            Wave1=nanmean(Wave1(:));
            RowId=table;RowId.Specification={'FrequencyChangeOverTime'}; RowId.NeuronType(:,1)={NeuronTypeId}; RowId.TimeMin(:,1)=TimeBinning(Tp); RowId.TimeMax(:,1)=TimeBinning(Tp+1);
            Table=addData2OutputTable(Table,Wave1,RowId,Mouse);
        end
        % make StdDev distribution
        Wave1=histcounts(Selection2.StdDev5,Edges2).';
        Wave1=Wave1/sum(Wave1)*100;
        
        Wave1=cumsum(Wave1);
        RowId=table;RowId.FrMin=Edges2(1:end-1); RowId.FrMax=Edges2(2:end); RowId.Specification(:,1)={'StdDevCumSum'}; RowId.NeuronType(:,1)={NeuronTypeId};
        Table=addData2OutputTable(Table,Wave1,RowId,Mouse);
        
        
        Selection3=Selection2(find(Selection2.TpCount>=3),:);
        % calculate mean Change for whole mouse
        Table=addData2OutputTable(Table,nanmean(Selection3.Change),struct('Specification',{{'MeanChange'}},'NeuronType',{{NeuronTypeId}}),Mouse);
        % Mean StdDev on all Neurons with more than 2 timepoints
        Table=addData2OutputTable(Table,nanmean(Selection3.Mean),struct('Specification',{{'MeanFrequency'}},'NeuronType',{{NeuronTypeId}}),Mouse);
%         MouseInfo.Mean(Mouse,NeuronType)=nanmean(Selection3.Mean);
        Table=addData2OutputTable(Table,nanmean(Selection3.StdDev),struct('Specification',{{'MeanStdDev'}},'NeuronType',{{NeuronTypeId}}),Mouse);
%         MouseInfo.StdDev(Mouse,NeuronType)=nanmean(Selection3.StdDev);
        Table=addData2OutputTable(Table,size(Selection3,1),struct('Specification',{{'NeuronCount3'}},'NeuronType',{{NeuronTypeId}}),Mouse);
%         MouseInfo.NeuronCount3(Mouse,NeuronType)=size(Selection3,1);
        % count neurons with more than 5 timepoints
        Wave1=find(Selection2.TpCount>=6);
%         MouseInfo.NeuronCount6(Mouse,NeuronType)=size(Wave1,1);
        Table=addData2OutputTable(Table,size(Wave1,1),struct('Specification',{{'NeuronCount6'}},'NeuronType',{{NeuronTypeId}}),Mouse);
%         MouseInfo.Slope(Mouse,NeuronType)=nanmean(Selection2.Slope);
        Table=addData2OutputTable(Table,nanmean(Selection2.Slope),struct('Specification',{{'Slope'}},'NeuronType',{{NeuronTypeId}}),Mouse);
        
        if size(Selection2,1)>0 % && NeuronType>1
            Wave1=nanmean(Selection2.Data,1);
%             MouseInfo.MeanTp(Mouse,NeuronType)={Wave1};
% % % % % % % %             Table=addData2OutputTable(Table,Wave1,struct('Specification',{{'MeanTp'}},'NeuronType',{{NeuronTypeId}}),Mouse);
            
            Timepoints=MouseInfo.IT(Mouse,:).';
            Wave1(isnan(Timepoints))=[];
            Timepoints(isnan(Timepoints))=[];
            Wave2=nan(max(Timepoints(:)),1); Wave2(Timepoints)=Wave1;
%             MouseInfo{Mouse,{['MeanTp',NeuronTypeId]}}(Timepoints)=Wave1;
            
            RowId=table;RowId.Day=(1:size(Wave2,1)).'; RowId.Specification(:,1)={'SparseFrequency'}; RowId.NeuronType(:,1)={NeuronTypeId};
            Table=addData2OutputTable(Table,Wave2,RowId,Mouse);
        end
    end
end

% % % % % each TreatmentType
% % % % TreatmentCategories=unique(MouseInfo.TreatmentType);
% % % % TreatmentData=table(TreatmentCategories,'VariableNames',{'Cat'});
% % % % for Cat=1:size(TreatmentCategories,1)
% % % %     CatId=TreatmentCategories{Cat};
% % % %     Ind=strfind1(MouseInfo.TreatmentType,CatId);
% % % %     Parameters={'Mean';'StdDev';'Slope';'Change';'ChangeAll';'ChangeNeuron';'ChangeTangle';'FrDistribution1All';'FrDistribution2All';'FrDistribution1Neuron';'FrDistribution2Neuron';'FrDistribution1Tangle';'FrDistribution2Tangle';'StdDevCumSumAll';'StdDevCumSumNeuron';'StdDevCumSumTangle'};
% % % %     for Param=1:size(Parameters,1)
% % % %         ParamId=Parameters{Param};
% % % %         TreatmentData(Cat,ParamId)={nanmean(table2array(MouseInfo(Ind,ParamId)),1)};
% % % %     end
% % % % end

% Table=Table(:,{'Specification','TimeMin','TimeMax','TimeBin','RadMin','RadMax','RadBin','Roi','Data'});
Table=Table(:,{'Specification','NeuronType','Timepoint','TimeMin','TimeMax','FrMin','FrMax','Day','Data'});

for m=size(Table,2)-1:-1:1
    Table=sortrows(Table,m);
end

%% export data into excel sheets
OutputPath=[Path2Folder,'\Results\'];
if exist(OutputPath)~=7
    mkdir(OutputPath);
end
[TableExport]=table2cell_2(Table);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId.');
TableExport=[TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType.';
% TableExport=[[MouseInfo.TreatmentType];TableExport];

OutputPath=[OutputPath,DataType,'_2.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(OutputPath);
% GroupData
% % % Wave1=table2cell_2(TreatmentData).';
% % % xlsActxWrite(Wave1,Workbook,['GroupData'],[],'Delete');
% MouseData
% Wave1=table2cell_2(MouseInfo).';
xlsActxWrite(TableExport,Workbook,['MouseData'],[],'Delete');
xlsActxWrite(FileData,Workbook,['FileData'],[],1);
xlsActxWrite(MouseInfo,Workbook,['MouseInfo'],[],'Delete');
Workbook.Save;
Workbook.Close;