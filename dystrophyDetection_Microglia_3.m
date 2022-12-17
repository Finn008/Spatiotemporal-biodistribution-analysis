function [Microglia,Soma,Fibers,Iba1,MicrogliaInfo]=dystrophyDetection_Microglia_3(FilenameTotal,FilenameTotalOrig,ChannelListOrig)
timeTable('Start');
global ShowIntermediateSteps; if ShowIntermediateSteps==1; Application=FilenameTotal; end;

Fileinfo=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};

MicrogliaInfo=struct;
[Iba1]=im2Matlab_3(FilenameTotalOrig,strfind1(ChannelListOrig,'Iba1',1));
Pix=size(Iba1).';
[Outside]=im2Matlab_3(FilenameTotal,'Outside');

ResCalc=[2;2;1];
[~,Window]=imdilateWindow([50;50;10],ResCalc,1);
[Iba1Perc97]=percentileFilter3D(Iba1,97,Window,Res,ResCalc,Outside); %
timeTable('Iba1Perc97');
Exclude=Outside; Exclude(Iba1>=Iba1Perc97)=1;

% 60th within 4*4µm
ResCalc=[0.3;0.3;Res(3)];
Window=round([4;4]./ResCalc(1:2)/2)*2+1;
[Iba1LocalPerc]=percentileFilter2D(Iba1,60,Window,Res,ResCalc,Exclude); % 4.2min
timeTable('Iba1Perc60');
Mask=(Iba1>=Iba1LocalPerc);

% 70th within 20*20µm
ResCalc=[1;1;Res(3)];
Window=round([20;20]./ResCalc(1:2)/2)*2+1;
[Iba1LocalPerc]=percentileFilter2D(Iba1,70,Window,Res,ResCalc,Exclude); % 4.2min
timeTable('Iba1Perc70');
Mask(Iba1<Iba1LocalPerc)=0;

% 90th within 200*200µm
% 100µm plaque, max 40% mic coverage, 200µm window: 1/4*40%=0.1
ResCalc=[5;5;Res(3)];
Window=round([200;200]./ResCalc(1:2)/2)*2+1;
[Iba1LocalPerc]=percentileFilter2D(Iba1,90,Window,Res,ResCalc,Exclude); % 4.2min
timeTable('Iba1Perc90');
Mask(Iba1<Iba1LocalPerc)=0;
clear Iba1LocalPerc;

Wave1=imerode(Mask,ones(3,3));
Wave1=imdilate(Wave1,ones(3,3));
Wave1(Mask==0)=0; Mask=Wave1;
% remove structures smaller than 1µm^3
BW=bwconncomp(Mask,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res);
Table=Table(Table.Volume>1,:);
Mask=zeros(Pix.','uint8');
Mask(cell2mat(Table.IdxList))=1;

if ShowIntermediateSteps==1; ex2Imaris_2(Mask,Application,'Microglia_All'); end
timeTable('All');

DetectNuclei=1;

if DetectNuclei==1
    [Soma,Distance,Wave1]=basinDetection(Mask,Outside,Res,struct('BasinThreshold',15,'ThresholdDistanceMean',10,'ShowBasinMap','DistanceMean'));
    if ShowIntermediateSteps==1; ex2Imaris_2(Distance,Application,'Microglia_DistanceIn'); end;
    if ShowIntermediateSteps==1; ex2Imaris_2(Wave1,Application,'Microglia_DistanceMean'); end;
    if ShowIntermediateSteps==1; ex2Imaris_2(Soma,Application,'Microglia_Soma'); end;
    
    if strfind1(Fileinfo.ChannelList{1},'Nuclei',1)
        [Nuclei]=im2Matlab_3(FilenameTotal,'Nuclei');
%         Nuclei=imdilate(Nuclei,strel('sphere',3));
%         Nuclei=imerode(Nuclei,strel('sphere',3));
    end
    NucleiData=table;
    NucleiData.PixelIdxList=label2idx(Nuclei).';
    NucleiData.NumPix=cellfun(@numel,NucleiData.PixelIdxList);
    NucleiData.Volume=NucleiData.NumPix*prod(Res(1:3));
    
    Wave1=accumarray_9(Nuclei,Soma,@sum,[],[],[],{1,0});
    NucleiData.MicrogliaSomaFraction(Wave1.Roi1,1)=double(Wave1.Value1)./double(NucleiData.NumPix)*100;
    
    if ShowIntermediateSteps==1
        ex2Imaris_2(matrixID2Value(Nuclei,NucleiData.MicrogliaSomaFraction),Application,'Microglia_SomaFraction');
    end
%     NucleiData(NucleiData.Volume<=4/3*3.1415*2^3,:)=[];
    NucleiData(NucleiData.MicrogliaSomaFraction<50,:)=[];
    BW=struct();BW.PixelIdxList=NucleiData.PixelIdxList.';BW.NumObjects=size(BW.PixelIdxList,2);BW.Connectivity=6;BW.ImageSize=Pix.';
    Nuclei=labelmatrix(BW); % separation lines between plaques have to be removed using Membership and PlaqueMap
    Mask(Nuclei>0)=1;
    [Distance,Membership]=distanceMat_4(Nuclei,{'DistInOut';'Membership'},Res,0.1,1,1,100,'uint16');

    if ShowIntermediateSteps==1; ex2Imaris_2(Distance,Application,'Microglia_DistanceInOut'); end;
    if ShowIntermediateSteps==1; ex2Imaris_2(Membership,Application,'Microglia_Membership'); end;
%     Wave1=imerode(Mask,imdilateWindow_2([1;1;1],Res,1,'ellipsoid'));
%     Soma=imdilate(Nuclei,imdilateWindow_2([1;1;1],Res,1,'ellipsoid'));
    Mask(Mask==1 & Distance<=110)=2; % 100=0, thus 1µm around
    if ShowIntermediateSteps==1; ex2Imaris_2(Mask,Application,'Microglia_Microglia2'); end;
    
    Skeleton=bwskel(logical(Mask));
    if ShowIntermediateSteps==1; ex2Imaris_2(Skeleton,Application,'Microglia_Skeleton'); end;
    
    imarisSaveHDFlock(FilenameTotal);
    Application=openImaris_4(FilenameTotal,[],1,1);
    keyboard;
    
    
    
    
    
    [Adjacency,Nodes,Links]=Skel2Graph3D(Skeleton,0);

    Nodes=struct2table(Nodes);
    Links=struct2table(Links);
    Links.NumPix=cellfun(@numel,Links.point);

    for Link=1:size(Links,1)
        Links.Endpoint(Link,1:2)=Nodes.ep([Links.n1(Link),Links.n2(Link)]).';
    end
    Links.Endpoint=sum(Links.Endpoint,2);
    
    % Links(Links.Endpoint>0 & Links.NumPix<=8,:)=[];
    Links(Links.Endpoint==1,:)=[];

    Wave1=struct('Connectivity',6,'ImageSize',Pix.','NumObjects',size(Links,1)); Wave1.PixelIdxList=Links.point.';
    LinkMap=labelmatrix(Wave1);

if ShowIntermediateSteps==1; ex2Imaris_2(LinkMap,Application,'Axons_2'); end;

    
    
    
    
    
    
    
    
    
    
    
    [DistanceIn]=distanceMat_4(~Soma,{'DistInOut'},Res,0.1,1,0,0,'uint16');
    if ShowIntermediateSteps==1; ex2Imaris_2(Distance,Application,'Microglia_Distance'); end;
    
    Version=struct('SeedImpact','Radius','Thresholds','Nuclei','Imdilation',1,'IdentifyLocalMaximaExtent',6,'WatershedUmBin',0.1,'ResCalc',0.2,'WatershedType','Morphology','DistanceDimensionality','XY');
    [Nuclei,LocalMaxima,WatershedDistance,Seeds]=watershedSegmentation_2(Nuclei,Version,Res);

    Soma2=Distance>=5;
    BW=bwconncomp(logical(Soma2),6);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
    Table.Volume=Table.NumPix*prod(Res(1:3));

    Basins=labelmatrix(BW);

    
    
    [DistanceOut]=distanceMat_4(Soma2,{'DistInOut'},Res,0.1,1,0,0,'uint16');
    
    
    
else
    Microglia=Mask;
    Soma=[];
    Fibers=[];
end

%% Finalize and make a quality control image

ex2Imaris_2(Microglia,FilenameTotal,'Microglia');
% Microglia=Microglia>0;
Iba12D=max(Iba1,[],3);
Wave1=double(prctile(Iba12D(:),99.99));
Iba12D=uint16(Iba12D/(Wave1/65535));
Colormap=repmat(linspace(0,1,65535).',[1,3]);
Image=ind2rgb(gray2ind(Iba12D,65535),Colormap);
if isempty(MicrogliaSoma)
    Microglia2D=uint16(max(Microglia,[],3));
else
    Microglia2D=uint16(max(MicrogliaFibers+2*uint8(MicrogliaSoma),[],3));
end
Colormap=[0,1,1;1,0,1];
Image(find(Microglia2D~=0))=Colormap(Microglia2D(Microglia2D~=0),1).*double(Iba12D(Microglia2D~=0))/65535;
Image(find(Microglia2D~=0)+prod(size(Image(:,:,1))))=Colormap(Microglia2D(Microglia2D~=0),2).*double(Iba12D(Microglia2D~=0))/65535;
Image(find(Microglia2D~=0)+2*prod(size(Image(:,:,1))))=Colormap(Microglia2D(Microglia2D~=0),3).*double(Iba12D(Microglia2D~=0))/65535;
[Path,Report]=getPathRaw([FilenameTotal,'_QualityControl_Microglia.tif']);
imwrite(Image,Path);





return;

%% detect nuclei
if DetectNuclei==1
    keyboard;
    Fileinfo=getFileinfo_2(FilenameTotal);
    ChannelList=Fileinfo.ChannelList{1};
    if strfind1(ChannelList,'Vglut1')
        % % %     Mask2=Skeleton3D(Mask);
        keyboard; % check if works
        SizeMinMax=[0.4,10;1.6,10;1.4,8.2]; % diameter 10
        [Islands]=detectIslands(1-Mask,SizeMinMax,Res,'3D','Ones10');
        
        [Vglut1]=im2Matlab_3(FilenameTotal,'Vglut1');
        [Outside]=im2Matlab_3(FilenameTotal,'Outside');
        [~,Vglut1Corr]=sparseFilter(Vglut1,Outside,Res,10000,[30;30;30],[5;5;5],85,'Multiply12000'); % set 85 percentile to 12000, previously 50th to 8000
        Threshold=prctile_2(Vglut1Corr,80,Outside==0); % 75=7200
        [MapVolume,MapDistInMax]=clusterAnalysis(Vglut1Corr<Threshold,Res,[0;0.025],[]);
        Mask2=Islands; Mask2(Vglut1Corr>Threshold)=0;
        Mask2=removeIslands_3(Mask2,4,[0;0.025],prod(Res(:)));
        
        J=struct;
        J.OutCalc=1;
        J.ZeroBin=0;
        J.Output={'DistInOut'};
        J.Res=Res;
        J.UmBin=0.1;
        [Out]=distanceMat_2(J,1-Mask);
        Distance=Out.DistInOut; clear Out;
        clear Mask;
        
        Watershed=uint8(10)-Distance; % previously 4
        
        Watershed=single(watershed(Watershed,26));
        
        Watershed(Distance==0)=0;
        BW=bwconncomp(Mask2,6);
        Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
        Table.Volume=Table.NumPix*prod(Res(1:3));
        Table=Table(Table.Volume>5,:);
        Mask2=zeros(Pix.','uint16');
        Mask2(cell2mat(Table.IdxList(:)))=1;
        
        Islands(Mask2==0)=0;
        IslandThreshold=5;
        clear Mask2;
    end
    
    
    Distance=distanceMat_4(Mask,{'DistInOut'},Res,0.1,1,0,0,'uint8'); % 5.8min
    % Watershed=max(Distance(:))-Distance;
    Watershed=uint8(20)-Distance;
    
    
    Watershed=single(watershed(Watershed,26)); % 13min
    Watershed(Distance==0)=0;
    BW=bwconncomp(logical(Watershed),26);
    
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
    Table.Volume=Table.NumPix*prod(Res(1:3));
    Table.Radius=(Table.Volume*3/4/3.1415).^(1/3);
    
    Wave1=labelmatrix(BW);
    Wave1=accumarray_9(Wave1,Distance,@max,[],[],[],{1,0});
    Table.DistInMax(Wave1.Roi1,1)=double(Wave1.Value1)/10;
    
    Wave1=zeros(Pix.','uint8');
    Table.DistInMaxUm=uint8(Table.DistInMax);
    for m=unique(Table.DistInMaxUm).'
        Wave1(cell2mat(Table.IdxList(Table.DistInMaxUm==m)))=m;
    end
    
    
    keyboard;
    if strfind1(FilenameTotal,'ExTanja')
        IslandThreshold=11;
        SizeMinMax=[0.4,6;1.5,6;1.5,6];
        [Islands]=detectIslands_2(1-Mask,SizeMinMax,Res,'3D','Ones10');
    end
    
    Mask(Islands>=IslandThreshold)=1;
    clear Islands;
    [Mask]=removeIslands_3(Mask,4,[0;1],prod(Res(:)));
    
    J=struct;
    J.OutCalc=1;
    J.ZeroBin=0;
    J.Output={'DistInOut'};
    J.Res=Res;
    J.UmBin=0.1;
    [Out]=distanceMat_2(J,1-Mask);
    Distance=Out.DistInOut; clear Out;
    
    DistanceThreshold=16;
    Nuclei=Distance>DistanceThreshold;
    clear Distance;
    
    J=struct;
    J.OutCalc=1;
    J.ZeroBin=0;
    J.Output={'DistInOut'};
    J.Res=Res;
    J.UmBin=0.1;
    [Out]=distanceMat_2(J,Nuclei);
    Distance2=Out.DistInOut; clear Out;
    
    Soma=Mask;Soma(Distance2>DistanceThreshold+3)=0;
    clear Distance2;
    
    BW=bwconncomp(Soma,6);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
    Table.Volume=Table.NumPix*prod(Res);
    Table.Diameter=(Table.Volume*3/4/3.1415).^(1/3)*2;
    Table(Table.Volume<100,:)=[];
    Soma=zeros(Pix.','uint16');
    for m=1:size(Table,1)
        Table.Iba1Mean(m,1)=mean(Iba1(Table.IdxList{m}));
        %     Table.Iba1CorrMean(m,1)=mean(Iba1Corr(Table.IdxList{m}));
        Soma(Table.IdxList{m})=m;
    end
    
    Fibers=Mask;Fibers(Soma~=0)=0;
    Microglia=Fibers+uint8(Soma>0)*2;
    
    
    J=struct;
    J.OutCalc=1;
    J.ZeroBin=0;
    J.Output={'DistInOut';'Membership'};
    J.Res=Res;
    J.UmBin=0.1;
    J.DistanceBitType='uint16';
    [Out]=distanceMat_2(J,Soma);
    Distance3=Out.DistInOut;
    Membership=Out.Membership;
    clear Out;
    
    % keyboard; % check if accumarray_8 provides same results as accumarray_2
    % keyboard; % Membership m==1 is missing
    [Table2]=accumarray_9({Distance3,'Distance';Membership,'Membership'},Fibers,@mean);
    Table2(Table2.Distance==0,:)=[];
    clear Distance3; clear Membership;
    % Table2.Properties.VariableNames={'Distance';'Membership';'Fraction'};
    Table.SomaCoverage(:,1:max(Table2.Distance))=NaN;
    for m=1:size(Table,1)
        Table.SomaCoverage(m,Table2.Distance(Table2.Membership==m))=Table2.Value1(Table2.Membership==m);
    end
    
    Soma=logical(Soma);
    
    Ind=find(Fibers==1);
    FiberInfo=struct;
    FiberInfo.MeanIba1=mean(Iba1(Ind));
    FiberInfo.Iba1CumSum=prctile_2(Iba1(:),(1:100).');
    % FiberInfo.MeanIba1Corr=mean(Iba1Corr(Ind));
    % FiberInfo.Iba1CorrCumSum=prctile_2(Iba1Corr(:),(1:100).');
    
    
    MicrogliaInfo.Somata=Table(:,{'Volume';'Diameter';'Iba1Mean';'SomaCoverage'});
    MicrogliaInfo.Fibers=FiberInfo;
end



