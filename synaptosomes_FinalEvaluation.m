function synaptosomes_FinalEvaluation()

global W;
FileList=W.G.T.F{W.Task};

% % % % Wave1=strfind1(FileList.Filename,{'ExSonjaB_IhcTubulin_M128_Trwt_Roi5';'ExSonjaB_IhcTubulin_M129_Trtg_Roi2'});
% % % % FileList=FileList(Wave1,:);

% Load data
BoutonData=table;

for File=1:size(FileList,1)
    Wave1=FileList.Synaptosomes{File,1};
    if strfind1(Wave1,'Step#1|')
        FileList.Included(File,1)=1;
    else
        continue;
    end
    
    FilenameTotal=FileList.Filename{File,1}; FilenameTotal=regexprep(FilenameTotal,{'.lsm'},'.ims');
    Path=[FilenameTotal,'_Results.mat'];
    [Path,Report]=getPathRaw(Path);
    if Report==0; continue; end;
    load(Path);
    Out=filenameExtract(FilenameTotal);
    Data2add=TotalResults.BoutonTable;
    Data2add.Experimentor(:,1)={TotalResults.MetaData.Ex};
    Data2add.MouseId(:,1)=TotalResults.MetaData.M;
    Data2add.TreatmentType(:,1)={TotalResults.MetaData.Tr};
    Data2add.Ihc(:,1)={TotalResults.MetaData.Ihc};
    Data2add.Res(:,1)=TotalResults.Fileinfo.Res;
    Data2add.Roi(:,1)=Out.Roi;
    Data2add.BoutonID(:,1)=(1:size(Data2add,1)).';
    Data2add=Data2add(:,{'TreatmentType';'MouseId';'Ihc';'Roi';'BoutonID';'CenterUm';'ImmunoId';'CenterUmImmuno';'ImmunoSpotDistance';'CenterPlaneVoxels';'CenterPlaneVoxelsImmuno';'Res'});
    BoutonData=[BoutonData;Data2add];
    FileList.BoutonNumber(File,1)=size(TotalResults.BoutonTable,1);
end
FileList=FileList(FileList.Included==1,:);

% calculate data for each synaptosome
[BoutonData]=synaptosomes_FinalEvaluation_BoutonCalculations(BoutonData);

BoutonData.Ratio_PostImmunoSumAll_PreVlgutSumAll=BoutonData.PostImmunoSumAll./BoutonData.PreVglutSumAll;
BoutonData.Ratio_PostImmunoSumHwi_PreVlgutSumHwi=BoutonData.PostImmunoSumHwi./BoutonData.PreVglutSumHwi;

BoutonData.Ratio_PreImmunoSumAll_PreVlgutSumAll=BoutonData.PreImmunoSumAll./BoutonData.PreVglutSumAll;
BoutonData.Ratio_PreImmunoSumHwi_PreVlgutSumHwi=BoutonData.PreImmunoSumHwi./BoutonData.PreVglutSumHwi;

BoutonData.Ratio_PostImmunoMeanAll_PreVlgutMeanAll=BoutonData.PostImmunoSumAll./BoutonData.PreVglutMeanAll;
BoutonData.Ratio_PostImmunoMeanHwi_PreVlgutMeanHwi=BoutonData.PostImmunoSumHwi./BoutonData.PreVglutMeanHwi;

BoutonData.Ratio_PreImmunoMeanAll_PreVlgutMeanAll=BoutonData.PreImmunoMeanAll./BoutonData.PreVglutMeanAll;
BoutonData.Ratio_PreImmunoMeanHwi_PreVlgutMeanHwi=BoutonData.PreImmunoMeanHwi./BoutonData.PreVglutMeanHwi;

% pool data
[Table,MouseInfo]=synaptosomes_FinalEvaluation_PoolData(BoutonData);

% export data to Excel
PathExcelExport=['\\GNP90N\share\Finn\Raw data\Synaptosomes.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(Table,Workbook,'MouseInfo',[],'DeleteOnlyContent');
Wave1=BoutonData;
Wave1(:,{'CenterPlaneVoxels';'CenterPlaneVoxelsImmuno'}) = [];
xlsActxWrite(Wave1,Workbook,'Synaptosomes',[],'DeleteOnlyContent');
Workbook.Save;
Workbook.Close;

