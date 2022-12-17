function [PlaqueMap,PlaqueData,Output]=wholeSliceQuantification_PlaqueDetection_2(MetBlue,Outside,Res)
CrudeDataVisualization=1;
Pix=size(MetBlue).';
Output=struct;
% calculate crude local 90th percentile, if small kernel then 90th percentile locally enhanced at plaques and plaques might be excluded
tic;
[MetBluePrc90]=percentileFilter_2(MetBlue,90,[27;27;3],Res,[20;20;Res(3)],Outside); % 500µm
disp(['MetBluePrc90: ',num2str(toc/60),' min']);

tic;
PlaqueCore=(MetBlue>=MetBluePrc90*3) & Outside==0; % previously factor 2
BW=bwconncomp(PlaqueCore,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
Table.Volume=Table.NumPix*prod(Res(1:3));
Table=Table(Table.Volume>=27,:);
% Table=Table(Table.Volume>0.5,:); % previously 2
BW.PixelIdxList=Table.PixelIdxList.';
BW.NumObjects=size(Table,1);
PlaqueCore=labelmatrix(BW);
clear BW;
disp(['PlaqueCore: ',num2str(toc/60),' min']);

tic
[DistanceFromCore,Membership]=distanceMat_4(PlaqueCore,{'DistInOut';'Membership'},Res,1,1,1,50,'uint16',0.8); % 3.5min
disp(['PlaqueCoreDistance: ',num2str(toc/60),' min']);
if size(unique(Membership(:)),1)~=size(unique(PlaqueCore(:)),1)-1 % zero bin
    keyboard;
% % %     PlaqueCore=Membership; % remove plaques that are removed due to data interpolation
% % %     PlaqueCore(DistInOut>50)=0;
end

if CrudeDataVisualization==1
    Res2=[1.6;1.6;1.6];
end

InsideVoxel=sum(Outside(:)==0);
Exclude=Outside;
Exclude(PlaqueCore>0)=1;
clear PlaqueBurden;
for Run=1:50
    tic
    [MetBlueLocalPrc]=percentileFilter_2(MetBlue,95,[13;13;1],Res,[2.4;2.4;Res(3)],Exclude); % 0.987min
    disp(['Finish ',num2str(toc/60),' min']);
    PlaqueMap=(MetBlue>MetBlueLocalPrc & Outside==0 & DistanceFromCore<=65) | PlaqueCore>0;
    
    % remove plaques that have no plaque core or are smaller than 3µm diameter
    BW=bwconncomp(PlaqueMap,6);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
    Table.Volume=Table.NumPix*prod(Res(1:3));
    PlaqueMap=labelmatrix(BW);
    clear BW;
    Wave1=PlaqueMap(PlaqueCore>0);
    Wave2=unique(Wave1); Wave2(Wave2==0)=[];
    Table=Table(Wave2,:);
    Table=Table(Table.Volume>=27,:);
    PlaqueMap=zeros(size(PlaqueMap),'uint8');
    PlaqueMap(cell2mat(Table.IdxList))=1;
    Exclude(PlaqueMap==1)=1;
    
    PlaqueBurden(Run,1)=sum(PlaqueMap(:))/InsideVoxel*100;
    if CrudeDataVisualization==1
        if Run==1
            PlaqueMap2=interpolate3D(PlaqueMap,Res,Res2)*100;
        else
            Wave1=interpolate3D(PlaqueMap,Res,Res2);
            PlaqueMap2(Wave1==1 & PlaqueMap2==0)=100-Run;
        end
    end
    disp(['Finish_Run: ',num2str(Run),', PlaqueBurden: ',num2str(PlaqueBurden(Run,1)),'%, Time: ',num2str(toc/60),' min']);
    if Run>1
        Wave1=PlaqueBurden(Run,1)/PlaqueBurden(Run-1,1)*100-100;
    end
    if Wave1<0.5
        break
    end
end
Output.PlaqueBurden=PlaqueBurden;

% [MetBlueLocalPrc]=percentileFilter_2(MetBlue,98,[13;13;1],Res,[2.4;2.4;Res(3)],Exclude); % 6min
[MetBlueLocalPrc]=percentileFilter_3(MetBlue,98,[13;13],Res,[2.4;2.4;Res(3)],Exclude); % 0.987min
PlaqueMap=(MetBlue>MetBlueLocalPrc & Outside==0 & DistanceFromCore<=65) | PlaqueCore>0;

% remove plaques that have no plaque core or are smaller than 3µm diameter
BW=bwconncomp(PlaqueMap,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
Table.Volume=Table.NumPix*prod(Res(1:3));
PlaqueMap=labelmatrix(BW);
Wave1=PlaqueMap(PlaqueCore>0);
Wave2=unique(Wave1); Wave2(Wave2==0)=[];
Table=Table(Wave2,:);

% Table=Table(Table.Volume>=27,:);
PlaqueMap=zeros(size(PlaqueMap),'uint16');
PlaqueMap(cell2mat(Table.PixelIdxList))=1;
PlaqueMap=PlaqueMap.*Membership;
BW.PixelIdxList=label2idx(PlaqueMap);
BW.NumObjects=size(BW.PixelIdxList,2);

Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
Table.Volume=Table.NumPix*prod(Res(1:3));
Table.RadiusFromVolume=(Table.Volume*3/4/3.1415).^(1/3);

% get maximal area in XY
tic;
Wave1=accumarray_8({PlaqueMap,'Roi1';repmat(permute(uint16(1:Pix(3)),[1,3,2]),[Pix(1),Pix(2),1]),'Roi2'},ones(Pix.','uint8'),@sum,'2D'); % 10min
disp(['Calculate2Darea: ',num2str(toc/60),' min']);
[Wave2,Wave3]=max(double(Wave1),[],2);
Table.MaxAreaXY=Wave2*prod(Res(1:2));
Table.ZpixMaxAreaXY=Wave3;
Table.RadiusAreaXYMax=(Table.MaxAreaXY/3.1415).^0.5;

Wave1=struct2table(regionprops(BW,'Centroid'));
Table.XYZpix=Wave1.Centroid;
Table.XYZpix(:,1:3)=Table.XYZpix(:,[2,1,3]);
Table.XYZum(:,1:3)=Table.XYZpix.*repmat(Res.',[size(Table,1),1]);
Table.XYZum=Table.XYZum-repmat((Pix.*Res).'/2,[size(Table,1),1]);

PlaqueData=Table;

% CrudeDataVisualization
if CrudeDataVisualization==1
    tic
    FilenameTotalTest='Test8.ims';
    MetBlue2=interpolate3D(MetBlue,Res,Res2);
    Outside2=interpolate3D(Outside,Res,Res2);
    MetBluePrc90_2=interpolate3D(MetBluePrc90,Res,Res2);
    PlaqueCore2=interpolate3D(PlaqueCore,Res,Res2);
    MetBlueBackgroundRatio2=interpolate3D(uint16(single(MetBlue)./single(MetBluePrc90)*100),Res,Res2);
    DistanceFromCore2=interpolate3D(DistanceFromCore,Res,Res2);
    MetBlueLocalPrc90_2=interpolate3D(MetBlueLocalPrc,Res,Res2);
    PlaqueMapFinal2=interpolate3D(PlaqueMap,Res,Res2);
%     DistanceFromPlaqueBorder_Res2=interpolate3D(DistanceFromPlaqueBorder,Res,Res2);
%     Membership_Res2=interpolate3D(MembershipFromPlaqueBorder,Res,Res2);
    
    dataInspector3D({MetBlue2;Outside2;MetBluePrc90_2;PlaqueCore2;MetBlueBackgroundRatio2;DistanceFromCore2;MetBlueLocalPrc90_2;PlaqueMap2;PlaqueMapFinal2},Res2,{'MetBlue';'Outside';'MetBluePrc90';'PlaqueCore';'MetBlueBackgroundRatio';'DistanceFromCore';'MetBlueLocalPrc90';'PlaqueMap';'PlaqueMapFinal'},1,FilenameTotalTest,1);
    disp(['SaveData2Imaris: ',num2str(toc/60),' min']);
    figure; plot(PlaqueBurden);
end

keyboard;
