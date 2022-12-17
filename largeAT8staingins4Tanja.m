function largeAT8staingins4Tanja(FileinfoOrig,FilenameTotalOrig,FilenameTotal)
global W;

PathTotalResults=[FilenameTotal,'_Results.mat'];
[PathTotalResults,ReportTotalResults]=getPathRaw(PathTotalResults);
Wave1=dir(PathTotalResults);
if ReportTotalResults==1 && Wave1.datenum>datenum('2016.12.10','yyyy.mm.dd')
    TotalResults=load(PathTotalResults);
    TotalResults=TotalResults.TotalResults;
else
    TotalResults=struct;
end

ResOrig=FileinfoOrig.Res{1};
Um=FileinfoOrig.Um{1};
PixOrig=FileinfoOrig.Pix{1};
Pix=round(Um./[1;1;1]);
Res=Um./Pix;

J=struct;J.PixMax=[Pix;0;1]; J.Resolution=Res; J.Path2file=W.PathImarisSample;

Application=openImaris_2(J);
% keyboard; % check if Resolution correct
[PathRaw,Report]=getPathRaw(FilenameTotal);
Application.FileSave(PathRaw,'writer="Imaris5"');
quitImaris(Application);
[Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);

% BrainArea
FilenameTotalBrainArea=regexprep(FilenameTotalOrig,'TyData.lsm','TyBrainArea.tif');
[PathRaw,Report]=getPathRaw(FilenameTotalBrainArea);
DataBrainArea=imread(PathRaw);
DataBrainArea=max(DataBrainArea,[],3);
DataBrainArea=DataBrainArea>100;
DataBrainArea=permute(DataBrainArea,[2,1]);
DataBrainArea=1-DataBrainArea;
DataBrainArea=interpolate3D(DataBrainArea,[],[],Pix);

%% determine Outside
Data3D=im2Matlab_3(FilenameTotalOrig,1);

DataRes111=interpolate3D(Data3D,[],[],Pix);
Percentile=80;
TargetValue=2000;
DataRes111=depthIntensityFitting_2(DataRes111,Res,Percentile,TargetValue,[],DataBrainArea==0,Fileinfo.Filename{1},'SteepFallingRaw');
ex2Imaris_2(DataRes111,FilenameTotal,'AT8');

Threshold=1000;

Outside=DataRes111<Threshold;
Outside=imdilate(Outside,imdilateWindow([3;3],Res));
Outside=imerode(Outside,imdilateWindow([51;51;3],Res));
Outside=imdilate(Outside,imdilateWindow([51;51;3],Res));
Outside=uint8(Outside);
Outside(DataBrainArea==0)=2;
ex2Imaris_2(Outside,FilenameTotal,'Outside');

% % % % BW=bwconncomp(Outside,6);
% % % % Table=table;
% % % % Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
% % % % Table.IdxList=BW.PixelIdxList.';
% % % % clear BW;
% % % % Res3D=prod(Res);
% % % % Table.Volume=Table.NumPix*Res3D;
% % % % Table=Table(Table.Volume>10000,:); % before 2016.12.22 Threshold 5000
% % % % Outside=zeros(size(Outside),'uint16');
% % % % for m=1:size(Table,1)
% % % %     Outside(Table.IdxList{m})=1;
% % % % end




%% get results


Threshold=prctile(DataRes111(Outside==0),80); % 50th 1092, 70th 1734, 80th 2310, 90th 3619

Array=DataRes111>Threshold;
BW=bwconncomp(Array,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res);
Table=Table(Table.Volume>=(4/3*3.14*8^3),:);
Array(:)=0;
Array(cell2mat(Table.IdxList))=1;

Mask=uint8(Array);

[Array,Nuclei]=removeIslands_3(Array,6,[0;15^3],prod(Res));
Wave1=imerode(Array,imdilateWindow([7;7;3],Res));
Wave1=imdilate(Wave1,imdilateWindow([9;9;3],Res));
Wave1(Array==0)=0;
Mask(Wave1==1)=2;
Mask(Nuclei==1)=3;

ex2Imaris_2(Mask,FilenameTotal,'Mask');

Mask(Outside~=0)=0;

Results=table;
InsideVox=sum(Outside(:)==0);
Results.InsideVolume=InsideVox*prod(Res);
Results.InsideFraction=InsideVox/prod(Pix)*100;
Wave1=sum(Mask(:)>0);
Results.All=Wave1/InsideVox*100;

Wave1=sum(Mask(:)>1);
Results.Soma=Wave1/InsideVox*100;

Wave1=sum(Mask(:)==3);
Results.SubthresholdNuclei=Wave1/InsideVox*100;

TotalResults.Results=Results;


% Application=openImaris_2(FilenameTotal,1);
% imarisSaveHDFlock(Application,FilenameTotal);
save(PathTotalResults,'TotalResults');

PathExcelExport=['\\GNP90N\share\Finn\Raw data\',Fileinfo.Filename{1},'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(Results,Workbook,'Results',[],'Delete');
Workbook.Save;
Workbook.Close;

imarisSaveHDFlock(FilenameTotal);
evalin('caller','global W;');