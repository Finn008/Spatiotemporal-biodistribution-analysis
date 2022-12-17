function finalEvaluation_UpdatePipeline(SingleStacks)
% keyboard;
global W;
PathExcelExport=['\\GNP90N\share\Finn\Raw data\SingleStacks.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(SingleStacks(:,{'Filename';'MouseId';'RoiId';'Time';'BoutonDetect';'RatioPlaque';'Date';'PlaqueIDs';'Res3D';'Res';'StatusRatioResults';'StatusDystrophies2Radius';'StatusAreaXY';'StatusArray3';'StatusDistanceReal'}),Workbook,'SingleStacks',[],'Delete');





Path=[W.PathExp,'\default\Excel\Pipeline_2.xlsx'];
[Excel,Workbook2,Sheets,SheetNumber]=connect2Excel(Path);
Pipeline=xlsActxGet(Workbook2,'Pipeline',1);


TaskList=W.G.T.F{5,1};

% Selection=SingleStacks.Filename(SingleStacks.StatusDystrophies2Radius==99,:);
Selection=SingleStacks.Filename(SingleStacks.StatusAreaXY==99,:);

for m=1:size(Selection,1)
    % add clock of Pipeline
    Ind=strfind1(TaskList.Filename,Selection{m});
    if size(Ind,1)>1
        A1=asdf;
    end
    TaskList.Notes10(Ind,1)={'Redo'};
    
    Ind2=strfind1(Pipeline.Filename,Selection{m});
    if size(Ind2,1)>1
        A1=asdf;
    end
    TaskList.Clock(Ind,1)=Pipeline.Clock(Ind2);
end

% PathExcelExport=['\\GNP90N\share\Finn\Raw data\SingleStacks.xlsx'];
% [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TaskList(:,{'Filename';'Notes10';'Clock'}),Workbook,'TaskList',[],'Delete');