function wholeSliceQuantification()
global W;
CrudeDataVisualization=1;


Timer=datenum(now);
tic;
F=W.G.T.F{W.Task}(W.File,:);
[FctSpec]=variableExtract(F.WholeSliceQuantification{1},{'Do';'Plaque';'Step';'ChannelNames';'StainingSpec'});
Res2=[1.6;1.6;1.6];
if strfind(F.Filename{1},'.')
    FilenameTotal=[F.Filename{1}(1:strfind(F.Filename{1},'.')-1),'.ims'];
    FilenameTotalOrig=F.Filename{1};
else
    FilenameTotal=[F.Filename{1},'.ims'];
    FilenameTotalOrig=[F.Filename{1},F.Type{1}];
end
if CrudeDataVisualization==1
    FilenameTotalCrude=regexprep(FilenameTotal,'.ims','_Crude.ims');
    Res2=[1.6;1.6;1.6];
end

[FileinfoOrig]=getFileinfo_2(FilenameTotalOrig);
FctSpec.Plaque=1;
if FctSpec.Plaque==1
    
    MetBlue=im2Matlab_3(FilenameTotalOrig,1); % load Methoxy-X04 data
    disp(['LoadMetBlue: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now); % 6.7min
    
    Pix=FileinfoOrig.Pix{1};
    Res=FileinfoOrig.Res{1};
    
    ResMin=[0.761;0.761;0.7999];
    Wave1=Res<ResMin;
    if max(Wave1(:))==1
        ResMin(Wave1==0)=Res(Wave1==0);
        [MetBlue,Out]=interpolate3D(MetBlue,Res,ResMin);
        Res=Out.Res;
        Pix=Out.Pix;
    end
    
    % get crude Outside
%     MaxProjection=max(MetBlue,[],3);
%     keyboard;
    [Outside,Outside2D]=wholeSliceQuantification_Outside(MetBlue,Res,FilenameTotal);
%     [Outside]=wholeSliceQuantification_Outside(MetBlue,Pix,Res,~Outside,FilenameTotal);
    disp(['Outside: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now); % 3.6min
    
    if isempty(Outside)
        return;
    end
    
    
    if strcmp(FctSpec.StainingSpec,'MethoxyPBS') % strfind1(FilenameTotal,'ExTanjaB')
        Core2BackgroundRatio=2;
    else
        Core2BackgroundRatio=3;
    end
    
    % correct for tilting
    [MetBlue]=wholeSliceQuantification_Tilting(MetBlue,Pix,Res,~Outside);
    disp(['Tilting: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now); % 4.9min
%     Outside=repmat(Outside,[1,1,Pix(3)]);
% % % %     % intensity depth correction
% % % %     
% % % %     [MetBlue,Output]=depthIntensityFitting_2(MetBlue,Res,50,1000,[],Outside,FilenameTotal);
% % % %     if max(Output.Error)==1
% % % %         A1=asdf;
% % % %     end
    
% % %     % exact Outside definition
% % %     if strcmp(FctSpec.StainingSpec,'MethoxyPBS') % strfind1(FilenameTotal,'ExTanjaB') | 
% % %         keyboard;
% % %         Wave1=MetBlue; Wave1(Outside)=0;
% % %         Wave1=permute(sum(sum(Wave1,1),2),[3,2,1]);
% % %         [~,Wave2]=sort(Wave1);
% % %         Wave2=Wave2(round((Pix(3)*Res(3)-50)/Res(3)):end);
% % %         CutEdges(3,1:2)=[min(Wave2);max(Wave2)];
% % %         Wave1(:)=1; Wave1(CutEdges(3,1):CutEdges(3,2))=0;
% % %         Outside(:,:,find(Wave1==1))=1;
% % %         
% % %         % export image 3D projection from side
% % %         MetBlue2D=max(MetBlue,[],1);
% % %         MetBlue2D=permute(MetBlue2D,[3,2,1]);
% % %         
% % %         Wave1=MetBlue2D(CutEdges(3,:),:);
% % %         Wave1=double(prctile(Wave1(:),90));
% % %         MetBlue2D=uint16(MetBlue2D/(Wave1/65535)); % 1500 to 256
% % %         
% % %         Colormap=repmat(linspace(0,1,65535).',[1,3]);
% % %         Image=ind2rgb(gray2ind(MetBlue2D,65535),Colormap);
% % %         Image(CutEdges(3,:),:,1)=1;
% % %         Image(CutEdges(3,:),:,2)=0;
% % %         Image(CutEdges(3,:),:,3)=1;
% % %         [Path,Report]=getPathRaw([FilenameTotal,'_4CheckTopBottom.tif']);
% % %         imwrite(Image,Path);
% % %     else
% % %         
% % %     end

    
%     if CrudeDataVisualization==1; ex2Imaris_2(interpolate3D(MetBlue,Res,Res2),FilenameTotalCrude,'MetBlue'); end;
    % % cut off slices with less than 1% Inside
    % % Wave1=permute(sum(sum(Outside,1),2),[3,2,1])/prod(size(Outside(:,:,1)))*100;
    
    % determine slice thickness
    Wave1=sum(Outside(:)==0);
    Wave2=min(Outside,[],3); Wave2=sum(Wave2(:)==0);
    SliceThickness=Wave1/Wave2*Res(3);
    
    
    %     if exist('CutEdges','Var')==0
    % cut vertically (X)
    Wave1=min(min(Outside,[],3),[],2);
    CutEdges(1,1)=find(Wave1==0,1);
    CutEdges(1,2)=Pix(1)-find(flip(Wave1)==0,1)+1;
    % cut horizontally (Y)
    Wave1=permute(min(min(Outside,[],3),[],1),[2,1]);
    CutEdges(2,1)=find(Wave1==0,1);
    CutEdges(2,2)=Pix(2)-find(flip(Wave1)==0,1)+1;
       
    %     end
    % cut depth
    Wave1=permute(sum(sum(MetBlue,1),2),[3,2,1]);
    Wave2=prctile(Wave1,SliceThickness/Res(3)/Pix(3)*100);
    CutEdges(3,1)=find(Wave1>=Wave2,1);
    CutEdges(3,2)=Pix(3)-find(flip(Wave1)>=Wave2,1)+1;
    CutEdges(3,1:2)=[1,Pix(3)];
    
    MetBlue=MetBlue(CutEdges(1,1):CutEdges(1,2),CutEdges(2,1):CutEdges(2,2),CutEdges(3,1):CutEdges(3,2));
    Outside=Outside(CutEdges(1,1):CutEdges(1,2),CutEdges(2,1):CutEdges(2,2),CutEdges(3,1):CutEdges(3,2));
    OrigPix=Pix;
    Pix=size(MetBlue).';
    if CrudeDataVisualization==1
        dataInspector3D(interpolate3D(MetBlue,Res,Res2),Res2,'MetBlue',1,FilenameTotalCrude,0);
    end
    
    [PlaqueMap,DistanceFromBorder,Membership,PlaqueData,MetBlueCorr]=wholeSliceQuantification_PlaqueDetection_5(MetBlue,Outside,Res,FilenameTotal,Core2BackgroundRatio);
    disp(['wholeSliceQuantification_PlaqueDetection: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now); % 187min
    
    if CrudeDataVisualization==1
        ex2Imaris_2(interpolate3D(PlaqueMap,Res,Res2),FilenameTotalCrude,'PlaqueMap');
        ex2Imaris_2(interpolate3D(Outside,Res,Res2),FilenameTotalCrude,'Outside');
    end
    if exist('CutEdges')~=1
        CutEdges=[0,0;0,0;0,0];
        OrigPix=Pix;
    end
    % include Outside TileFrame
    TilePix=FileinfoOrig.Results{1,1}.ZenInfo.TilePix;
    Wave1=[(TilePix(1):TilePix(1):OrigPix(1)).']-CutEdges(1,1); Wave1=[1;Wave1;Wave1+1];
    Wave1=Wave1(find(Wave1>0 & Wave1<=Pix(1)));
    Outside(Wave1,:,:)=1;
    Wave1=[(TilePix(2):TilePix(2):OrigPix(2)).']-CutEdges(2,1); Wave1=[1;Wave1;Wave1+1];
    Wave1=Wave1(find(Wave1>0 & Wave1<=Pix(2)));
    Outside(:,Wave1,:)=1;
    
    % determine if plaques touch the border of SubTiles
    Wave1=unique(PlaqueMap(Outside~=0&PlaqueMap~=0));
    PlaqueData.BorderTouch(Wave1,1)=1;
    
    % export image 3D projection for drawing brain regions
    MetBlue2D=max(MetBlue,[],3);
    Outside2D=uint16(min(Outside,[],3));
    Wave1=imdilate(1-Outside2D,imdilateWindow([10;10],Res));
    Outside2D(Wave1==0)=0;
    
    Wave1=double(prctile(MetBlue2D(Outside2D==0),98));
    MetBlue2D=uint16(MetBlue2D/(Wave1/65535)); % 1500 to 256
    Colormap=repmat(linspace(0,1,65535).',[1,3]);
    Image=ind2rgb(gray2ind(MetBlue2D,65535),Colormap);
    
    
    Image(find(Outside2D(:)))=1;
    Image(prod(size(Image(:,:,1)))+find(Outside2D(:)))=0;
    Image(2*prod(size(Image(:,:,1)))+find(Outside2D(:)))=1;
    
    PlaqueMap2D=uint16(max(PlaqueMap,[],3));
    Colormap=rand(65535,3);
    Image(find(PlaqueMap2D~=0))=Colormap(PlaqueMap2D(PlaqueMap2D~=0),1).*double(MetBlue2D(PlaqueMap2D~=0))/65535;
    Image(find(PlaqueMap2D~=0)+prod(size(Image(:,:,1))))=Colormap(PlaqueMap2D(PlaqueMap2D~=0),2).*double(MetBlue2D(PlaqueMap2D~=0))/65535;
    Image(find(PlaqueMap2D~=0)+2*prod(size(Image(:,:,1))))=Colormap(PlaqueMap2D(PlaqueMap2D~=0),3).*double(MetBlue2D(PlaqueMap2D~=0))/65535;
    % % %     try
    % % %         Image=insertText(Image,[1,1],num2str(PlaqueListSingle3.Time2Treatment(Ind)),'FontSize',10,'BoxColor','w');
    % % %     end
    [Path,Report]=getPathRaw([FilenameTotal,'_4RegionMarking.tif']);
    imwrite(Image,Path);
    
    % export 3D projection with corrected MetBlue
    keyboard;
    ChannelInfo=table;
    ChannelInfo(1,{'Channel','Colormap','ColorMinMax','Data'})={'MetBlueCorr',{[1;1;1]},{[0;prctile(MetBlueCorr(Outside==0),90)]},max(MetBlueCorr.*uint16(Outside==0),[],3)};
%     ChannelInfo(2,{'Channel','Colormap','ColorMinMax','Data'})={'Dystrophies',{[1;0;1]},{[0;10000]},max(APP.*uint16(Mask>0),[],3)};
    Path2file=getPathRaw([FilenameTotal,'_MetBlueCorr.tif']);
    imageGenerator(ChannelInfo,Path2file);
    
       
    
    % visualize the data
    Membership_Res2=interpolate3D(Membership,Res,Res2);
    DistanceFromBorder_Res2=interpolate3D(DistanceFromBorder,Res,Res2);
    MetBlue_Res2=interpolate3D(MetBlue,Res,Res2);
    
    dataInspector3D({MetBlue_Res2;Membership_Res2;DistanceFromBorder_Res2},Res,{'MetBlue';'Membership';'Distance'},1,FilenameTotal,0);
    disp(['VisualizeData3D: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now); % 8.8min
    
    PathFinalResults=[FileinfoOrig.Filename{1},'_FinalResults.mat'];
    [PathFinalResults,Report]=getPathRaw(PathFinalResults);
    if Report==1
        load(PathFinalResults);
    else
        FinalResults=struct;
    end
    PlaqueData(PlaqueData.Volume==0,:)=[];
    
    % FinalResults=struct;
    try; FinalResults.SliceThickness=SliceThickness; end;
    FinalResults.CutEdges=CutEdges;
    FinalResults.FilenameTotalOrig=FilenameTotalOrig;
    FinalResults.PlaqueData=PlaqueData;
    FinalResults.TilePix=TilePix;
    FctSpec.Step=1;
    FctSpec.Do='Fin';
    FctSpec.Plaque=2;
end
[Path,Report]=getPathRaw([FilenameTotal,'_4RegionMarking_Finish.tif']);
if Report==1 % previously 1
    DataBrainArea=permute(imread(Path),[2,1,3]);
    DataBrainArea=DataBrainArea(CutEdges(1,1):CutEdges(1,2),CutEdges(2,1):CutEdges(2,2),:);
    
    DataBrainArea2D=max(DataBrainArea,[],3);
    DataBrainArea2D(DataBrainArea2D>0)=1;
    
    ColorCoding={[0,0,0],'Outside',0;...
        'grey','RemainingBrain',1;...
        [255,0,255],'Cortex',2;... % magenta
        [0,255,255],'Hippocampus',3;... % cyan
        };
    ColorCoding=array2table(ColorCoding,'VariableNames',{'RGB';'BrainRegion';'Index'});
    ColorCoding.Index=cell2mat(ColorCoding.Index);
    
    for Col=3:size(ColorCoding,1) % 3 not 1 because first two not necessary
        DataBrainArea2D(DataBrainArea(:,:,1)==ColorCoding.RGB{Col}(1) & DataBrainArea(:,:,2)==ColorCoding.RGB{Col}(2) & DataBrainArea(:,:,3)==ColorCoding.RGB{Col}(3))=ColorCoding.Index(Col);
    end
    DataBrainArea3D=repmat(DataBrainArea2D,[1,1,Pix(3)]);
    DataBrainArea3D(Outside==1)=0;
    
    [Wave2]=ismember(ColorCoding.Index,unique(DataBrainArea2D(:)));
    Table=ColorCoding(Wave2,:);
   
    DataBrainArea3D_Res2=interpolate3D(DataBrainArea3D,Res,Res2);
    PlaqueMap_Res2=interpolate3D(PlaqueMap,Res,Res2);
    DistanceFromBorder_Res2=interpolate3D(DistanceFromBorder,Res,Res2);
    MetBlue_Res2=interpolate3D(MetBlue,Res,Res2);
    Pix2=size(PlaqueMap_Res2).';
    % 3D Volume
    Wave1=accumarray_9({DataBrainArea3D_Res2,'BrainRegion'},ones(size(DataBrainArea3D_Res2),'uint8'),@sum,[],[],[]);
    Table.BrainVolume=Wave1.Value1*prod(Res2(:));
    
    Wave1=accumarray_9({DataBrainArea3D_Res2,'BrainRegion'},logical(PlaqueMap_Res2),@sum,[],[],[]);
    Table.PlaqueVolume=Wave1.Value1*prod(Res2(:));
    Table.PlaqueFraction3D=Table.PlaqueVolume./Table.BrainVolume*100;
    
    % 3D distance distribution
    Wave1=accumarray_9({DataBrainArea3D_Res2,'BrainRegion';DistanceFromBorder_Res2,'Distance'},ones(size(DistanceFromBorder_Res2),'uint8'),@sum,[],[],[]);
    Wave1.Volume=Wave1.Value1*prod(Res2(:));
    Wave1.Distance=int16(Wave1.Distance)-50;
    Wave1=Wave1(Wave1.Distance<=500,:);
    for m=1:size(Table,1)
        Table.DistanceDistribution{m,1}=Wave1(Wave1.BrainRegion==Table.Index(m),{'Distance';'Volume'});
    end
    
    % Plaque size distribution
    Wave1=round(PlaqueData.XYZpix.*repmat((Res./Res2).',[size(PlaqueData,1),1])); Wave1(Wave1==0)=1;
    Wave1=sub2ind(Pix2,Wave1(:,1),Wave1(:,2),Wave1(:,3));
    PlaqueData.BrainRegion=DataBrainArea3D_Res2(Wave1);
    PlaqueData2=PlaqueData(PlaqueData.BorderTouch==0,:);
    Wave1=accumarray_9({PlaqueData2.BrainRegion,'BrainRegion';ceil(PlaqueData2.RadiusMaxIntSum),'Radius'},ones(size(PlaqueData2,1),1,'uint8'),@sum,[],[],[]);
    Wave1.Density=Wave1.Value1;
    for m=1:size(Table,1)
        Wave2=Wave1(Wave1.BrainRegion==Table.Index(m),{'Radius';'Density'});
        Wave2.Density=Wave2.Density/Table.BrainVolume(m);
        Table.RadiusDistribution{m,1}=Wave2;
    end
    
    % 2D
    PlaqueMap2D=max(PlaqueMap,[],3);
    Wave1=accumarray_9({DataBrainArea2D,'BrainRegion'},ones(size(DataBrainArea2D),'uint8'),@sum,[],[],[]);
    Table.BrainArea=Wave1.Value1*prod(Res2(1:2));
    
    Wave1=accumarray_9({DataBrainArea2D,'BrainRegion'},logical(PlaqueMap2D),@sum,[],[],[]);
    Table.PlaqueArea=Wave1.Value1*prod(Res2(1:2));
    Table.PlaqueFraction2D=Table.PlaqueArea./Table.BrainArea*100;
    
    FinalResults.RegionInfo=Table;
    
    OutputTable=table;
    OutputTable('BrainRegion',{'Specification';'Distance';'Radius';'Data'})={{'BrainRegion'},NaN,NaN,Table.Index.'};
    for m={'BrainVolume';'PlaqueVolume';'PlaqueFraction3D';'BrainArea';'PlaqueArea';'PlaqueFraction2D'}.'
        OutputTable{m,'Specification'}=m;
        OutputTable{m,'Data'}=Table{:,m}.';
    end
        
    for m=1:size(Table,1)
        RowId=table; RowId.Distance=Table.DistanceDistribution{m}.Distance; RowId.Specification(:,1)={'DistanceDistribution'};
        OutputTable=addData2OutputTable_2(OutputTable,Table.DistanceDistribution{m}.Volume,RowId,m);
        
        RowId=table; RowId.Radius=Table.RadiusDistribution{m}.Radius; RowId.Specification(:,1)={'RadiusDistribution'};
        OutputTable=addData2OutputTable_2(OutputTable,Table.RadiusDistribution{m}.Density,RowId,m);
    end
    
    OutputTable=sortrows(OutputTable,{'Specification','Distance','Radius'},{'ascend','ascend','ascend'});
    
    ExcelFilename=[FileinfoOrig.Filename{1},'_Results'];
    PathExcelExport=['\\GNP90N\share\Finn\Raw data\',ExcelFilename,'.xlsx'];
    [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
    [TableExport]=table2cell_2(OutputTable);
    TableExport(1,end-size(Table,1)+1:end)=Table.BrainRegion.';
%     TableExport=[TableExport(1,:);TableExport];
%     TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType.';
    xlsActxWrite(TableExport,Workbook,'BrainRegion',[],'Delete');
    xlsActxWrite(PlaqueData,Workbook,'PlaqueData',[],'Delete');
    Workbook.Save;
    Workbook.Close;
end

save(PathFinalResults,'FinalResults');
FctSpec=struct2table(FctSpec);
FctSpecOut=cell(0,2);
for m=1:size(FctSpec,2)
    if FctSpec{1,m}~=0
        FctSpecOut=[FctSpecOut;{FctSpec.Properties.VariableNames{m},num2str(FctSpec{1,m})}];
    end
end

Wave1=variableSetter_2(W.G.T.F{W.Task,1}.WholeSliceQuantification{W.File},FctSpecOut);
iFileChanger('W.G.T.F{W.Task,1}.WholeSliceQuantification{W.File}',Wave1);

disp(['Final: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now); % ?min
% MetBluePrc90: 0.42827 min
% PlaqueCore: 0.9999 min
% DistanceTransform:
% PlaqueCoreDistance: 41.429 min
% MetBlueLocalPrc: 29.666 min
% Gaussian: 41.6048 min
% Watershed: 99.2664 min
% DistanceTransform:
% DistanceFromPlaqueBorder: 42.1596 min
% Calculate2Darea: 16.5094 min
% arthur3Z91IA locking mouseMove since 2017.06.27 20:59
% arthur3Z91IA locking mouseMove since 2017.06.27 21:08
% SaveData2Imaris: 15.0136 min


% MetBluePrc90: 0.94962 min
% PlaqueCore: 1.4706 min
% DistanceTransform: 
% PlaqueCoreDistance: 97.4102 min
% MetBlueLocalPrc: 69.353 min
% Gaussian: 105.9045 min
% Watershed: 377.3606 min
% DistanceTransform: 
% DistanceFromPlaqueBorder: 57.0674 min


% LoadMetBlue: 7.2 min
% OutsieCrude: 0.2 min
% Tilting: 2.8 min
% Outside: 3.6 min
% MetBluePrc70: 1.8 min
% PlaqueCore: 0.8 min
% PlaqueCoreDistance: 23.1 min
% MetBlueLocalPrc: 17 min
% Gaussian: 23.4 min
% Watershed: 56.2 min
% Roundation: 1.6 min
% DistanceFromPlaqueBorder: 30.7 min
% RemoveIslands: 31.3 min
% wholeSliceQuantification_PlaqueDetection: 187.4 min
% VisualizeData3D: 8.8 min

% LoadMetBlue: 9.4 min
% OutsideCrude: 0.2 min
% Tilting: 16.5 min
% Outside: 7.2 min
% MetBluePrc70: 3.2 min
% % PlaqueCore: 1.2 min
% % PlaqueCoreDistance: 43.1 min
% % MetBlueLocalPrc: 29.4 min
% % Gaussian: 38.9 min
% % Watershed: 83.3 min
% % Roundation: 1.7 min
% % DistanceFromPlaqueBorder: 24 min
% RemoveIslands: 13.9 min
% wholeSliceQuantification_PlaqueDetection: 239.7 min
% VisualizeData3D: 3.2 min
% Final: 0 min