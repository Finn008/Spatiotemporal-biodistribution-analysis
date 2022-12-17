function dystrophyDetection_finalBoutons(MouseInfo,SingleStacks)
global W;
BoutonList=table;
BoutonListMat=table;
for Row=1:size(SingleStacks,1)
    if isempty(SingleStacks.BoutonInfo{Row})
        continue;
    end
    % Define order of channels
    ChannelNames=SingleStacks.BoutonInfo{Row,1}.Boutons1.ChannelNames;
    if isequal(ChannelNames,{'Vglut1';'Outside';'Vglut1Corr';'Vglut1Corr2'})==0
        keyboard;
    end
    
    Boutons1=SingleStacks.BoutonInfo{Row,1}.Boutons1.ObjInfo(:,:);
    Boutons1.Version(:,1)=1;
    Boutons1.Properties.RowNames=cell(0,0);
%     Data2Add=Boutons1;
    Boutons2=SingleStacks.BoutonInfo{Row,1}.Boutons2.ObjInfo;
    Boutons2.Version(:,1)=2;
    Boutons2.Properties.RowNames=cell(0,0);
%     Data2Add(end+1:end+size(Boutons2,1),Boutons2.Properties.VariableNames)=Boutons2(:,Boutons2.Properties.VariableNames);
    AddBoutonList=[Boutons1;Boutons2];
    
    VariableNames={'Filename';'MouseId';'Roi';'TreatmentType'};
    AddBoutonList(:,VariableNames)=repmat(SingleStacks(Row,VariableNames),[size(AddBoutonList,1),1]);
    BoutonList=[BoutonList;AddBoutonList];
    
    try
        Boutons3=SingleStacks.BoutonInfo{Row,1}.Boutons3;
        Boutons3.Version(:,1)=3;
        Boutons3.Properties.RowNames=cell(0,0);
        try; Boutons3(:,'IdxList')=[]; end;
        try; Boutons3(:,'NumPix')=[]; end;
        AddBoutonListMat=[Boutons3];
        AddBoutonListMat(:,VariableNames)=repmat(SingleStacks(Row,VariableNames),[size(AddBoutonListMat,1),1]);
        BoutonListMat=[BoutonListMat;AddBoutonListMat];
    end
    
    
    
    

%     Boutons3.DiameterX=Boutons3.MinRadius*2;
%     try; Boutons3(:,'MinRadius')=[]; end;
%     Wave1=[nan(size(Boutons3,1),Boutons3.IntensityMean,nan(size(Boutons3,1),];
    
    %     Data2Add(end+1:end+size(Boutons3,1),Boutons3.Properties.VariableNames)=Boutons3(:,Boutons3.Properties.VariableNames);

    
    
    
    SingleStacks.OutsideVolume(Row,1)=SingleStacks.BoutonInfo{Row,1}.OutsideVolume;
    SingleStacks.InsideVolume(Row,1)=SingleStacks.BoutonInfo{Row,1}.InsideVolume;
    
end


ExcelFilename=[W.G.T.TaskName{W.Task},'_BoutonInfo'];
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',ExcelFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);

MouseInfo=[MouseInfo([1:13,18:24,14:17,32,34:36,28,29,31,33,25:27,30],:)];
[Table]=dystrophyDetection_finalBoutons_Selection(BoutonListMat,MouseInfo,SingleStacks,{'Vglut1Corr2'},3,[],[],'Exclude');
xlsActxWrite(Table,Workbook,'Output13',[],'Delete');

[Table]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,1,[],0.0001,'Exclude');
xlsActxWrite(Table,Workbook,'Output1',[],'Delete');
[Table]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,1,[],0.0001,'Include');
xlsActxWrite(Table,Workbook,'Output2',[],'Delete');
[Table]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,2,[],0.0001,'Exclude');
xlsActxWrite(Table,Workbook,'Output3',[],'Delete');
[Table]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,2,[],0.0001,'Include');
xlsActxWrite(Table,Workbook,'Output4',[],'Delete');

[Table]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,1,[0.1;99],0.0001,'Exclude');
xlsActxWrite(Table,Workbook,'Output5',[],'Delete');
[Table]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,1,[0.1;99],0.0001,'Include');
xlsActxWrite(Table,Workbook,'Output6',[],'Delete');
[Table]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,2,[0.1;99],0.0001,'Exclude');
xlsActxWrite(Table,Workbook,'Output7',[],'Delete');
[Table]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,2,[0.1;99],0.0001,'Include');
xlsActxWrite(Table,Workbook,'Output8',[],'Delete');

[Table]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,1,[0.4;99],0.0001,'Exclude');
xlsActxWrite(Table,Workbook,'Output9',[],'Delete');
[Table]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,2,[0.4;99],0.0001,'Exclude');
xlsActxWrite(Table,Workbook,'Output10',[],'Delete');

[Table]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,2,[0.4;99],0.0001,'Include',[0;5]);
xlsActxWrite(Table,Workbook,'Output11',[],'Delete');

[Table]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,2,[0.4;99],0.0001,'Include',[0;5]);
xlsActxWrite(Table,Workbook,'Output12',[],'Delete');

Workbook.Save;
Workbook.Close;

% keyboard;
