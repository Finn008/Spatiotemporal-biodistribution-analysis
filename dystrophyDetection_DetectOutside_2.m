function [Output]=dystrophyDetection_DetectOutside_2(Specimen,DataBrainArea)

timeTable('DetectOutside_Start');
global NameTable; global ChannelTable;
Output=[];
Fileinfo=getFileinfo_2(NameTable.Filename{'FilenameTotalOrig'});
Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};

global ShowIntermediateSteps;
if exist('ShowIntermediateSteps','Var') && ShowIntermediateSteps==1
    Application=ChannelTable.TargetFilename{'ShowIntermediate'};
end


if strcmp(Specimen,'Chunk')
    [Outside,Output]=dystrophyDetection_Outside_7(DataBrainArea);
    ex2Imaris_2(Outside,ChannelTable.TargetFilename{'Outside'},'Outside',1,Res);
    % calculate thickness of brain slice
    MaxProjection=double(permute(sum(sum(Outside,1),2),[3,2,1]));
    MaxProjection=1-(MaxProjection/max(MaxProjection(:)));
    
    Output.SliceThickness=mean(MaxProjection(:))*Pix(3)*Res(3);
    Output.TotalVolume=sum(Outside(:))*prod(Res(1:3));

elseif strcmp(Specimen,'WholeSlice')
    
elseif strcmp(Specimen,'InToto')
    if strfind1(ChannelTable.ChannelName,'XrayPhase')
        keyboard;
        Outside=im2Matlab_4(NameTable.Filename{'FilenameTotal'},'XrayPhase');
        Path2file=getPathRaw([NameTable.Filename{'FilenameImarisLoadTif'},'_Cropped.tif']);
        Outside2D=imread(Path2file);
        Outside2D=Outside2D(:,:,1)<128;
        Ydim=min(Outside2D,[],1).';
        Xdim=min(Outside2D,[],2);
        Cut=[find(Xdim==0,1),size(Outside2D,1)-find(flip(Xdim)==0,1);find(Ydim==0,1),size(Outside2D,2)-find(flip(Ydim)==0,1)];
        Outside2D=Outside2D(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2));
        Outside(repmat(Outside2D,[1,1,Pix(3)])==1)=0;
        
        Wave1=Outside(repmat(Outside2D,[1,1,Pix(3)])==0);
        Threshold=prctile(Wave1(:),50)*1.3; % previously 2*90th
        ResCalc=[10;10;10];
        Wave1=interpolate3D_3(Outside>Threshold,[],Res,ResCalc);
        [~,Distance,BasinMap]=basinDetection(Wave1,[],ResCalc,struct('BasinThreshold',100,'ThresholdDistanceMean',50,'ShowBasinMap','DistanceMean','ResCalc',ResCalc(1),'DistanceRes',1,'Border2void',1));
        BasinMap=imdilate(BasinMap>=200,imdilateWindow_2([30;30;30],ResCalc,1,'ellipsoid'));
        Wave1(BasinMap==1)=0;
        [~,Distance,BasinMap]=basinDetection(Wave1,[],ResCalc,struct('BasinThreshold',100,'ThresholdDistanceMean',50,'ShowBasinMap','DistanceMean','ResCalc',ResCalc(1),'DistanceRes',1,'Border2void',1));
        Outside=interpolate3D_3(BasinMap>=200,Pix);
        
        if ShowIntermediateSteps==1
%             PixInter=[317;317;195];
            ex2Imaris_2(Outside,Application,'Outside_Xrayphase_2',1,Res);
%             imarisSaveHDFlock(ChannelTable.TargetFilename{'ShowIntermediate'});
%             Application=openImaris_4(Application,[],1,1);
        end
%         ex2Imaris_2(Distance,'Test1205.ims','Distance',1,ResCalc);
%         imarisSaveHDFlock('Test1205.ims');
%         Application=openImaris_4('Test1205.ims',[],1,1);
%         ex2Imaris_2(Distance,Application,'Distance');
%         ex2Imaris_2(interpolate3D_3(uint16(Outside),size(Distance)),Application,'XrayPhase');
%         ex2Imaris_2(BasinMap,Application,'BasinMap');
%         ex2Imaris_2(Wave1,Application,'Test');
    elseif strfind1(ChannelTable.ChannelName,'CongoRed')
        ResCalc=[5;5;5];
        Outside=im2Matlab_4(NameTable.Filename{'FilenameTotalOrig'},'CongoRed',1,ResCalc);
        
        Threshold=double(prctile(Outside(:),10));
        if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Outside/(Threshold/100),[],ResCalc,ChannelTable.Res{'ShowIntermediate'}),Application,'Outside_PercentileFactor'); end;
        Threshold=Threshold*2; % previously *4
        
        BW=bwconncomp(Outside>Threshold,6);
        Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
        Table.Volume=Table.NumPix*prod(ResCalc(1:3));
        Table=Table(Table.Volume>2000^3,:);
        Outside(:)=1;
        Outside(cell2mat(Table.IdxList))=0;
        clear BW;
    end
    ex2Imaris_2(Outside,ChannelTable.TargetFilename{'Outside'},'Outside',1,ResCalc);
end
