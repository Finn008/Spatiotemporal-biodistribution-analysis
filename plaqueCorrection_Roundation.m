function [PlaqueData,PlaqueMapTotal]=plaqueCorrection_Roundation(FilenameTotal,RoundationType,PlaqueMapTotal,RealPlaquesTotal,OutsideMap)

global W;
Fileinfo=getFileinfo_2(FilenameTotal);

Pix=Fileinfo.Pix{1};
Res=Fileinfo.Res{1};
Timepoints=Fileinfo.GetSizeT;
% determine how much surface of coreplaque borders to outside chunk (RealPlaqueCh==10)
% to RealPlaqueCh add outer shell of 0 to incorporate total Border

PlaqueData=table(repmat({table},[500,1]),'VariableNames',{'Data'});
cprintf('text','Calculating plaque dimension:');
for Time=1:Timepoints
    cprintf('text',[' ',num2str(Time),',']);
    PlaqueIDs=unique(PlaqueMapTotal(:,:,:,Time));
    PlaqueIDs(PlaqueIDs==0,:)=[];
    PlaqueMapCorr=zeros(Pix.','uint8');
    [MetBlue]=im2Matlab_3(FilenameTotal,'MetBlue',Time);
    
    PlaqueCh=MetBlue; % PlaqueCh=MetBlue-1;
    
    % define outside (outside is set to 1 in MetBlue)
    if exist('OutsideMap')==1
        Outside=OutsideMap(:,:,:,Time);
    else
        FA=ratioPlaque_Data2Trace({'Outside'},[],{'TargetTimepoint';Time});
        Outside=FA.TargetChannel{1,1};
        Outside=uint8(Outside>1);
        Outside(MetBlue<1)=1;
    end
    
           
% % % %     keyboard; % calculate the total brain volume and save it to the Results.mat file, required for plaque formation
    
    StackOut=zeros(size(MetBlue)+[2,2,0],'uint8'); % to define border
    StackOut(2:end-1,2:end-1,:)=1-Outside;
    clear MetBlue; clear Outside;
    
    for Pl=PlaqueIDs.'
%         disp(Pl);
        %% define the center of each plaque
        PlaqueMask=uint8(PlaqueMapTotal(:,:,:,Time)==Pl);
        if sum(PlaqueMask(:))==1
            Wave1=find(PlaqueMask==1);
            PlaqueCh(Wave1)=1; % to circumvent it to be zero
            GhostPlaque=1;
        else
            GhostPlaque=0;
        end
        PlaqueChPl=PlaqueCh.*cast(PlaqueMask,class(PlaqueCh));
        IntensityProfile=permute(sumdims(PlaqueChPl,[1,2]),[3,2,1]);
        [~,LayIntOrder]=sort(IntensityProfile);
        Wave1=ceil(sum(IntensityProfile>0)/4); % choose 25% brightest slices

        clear XYZCenter;
        PixCenter(3,1)=round(mean(LayIntOrder(end-Wave1+1:end)));
        
        % determine central band
        CentralBand=[floor(PixCenter(3,1)-2.5/Res(3));ceil(PixCenter(3,1)+2.5/Res(3))];
        CentralBand(CentralBand<1)=1;
        CentralBand(CentralBand>Pix(3))=Pix(3);
        
        try
            Wave1=PlaqueMask(:,:,CentralBand(1):CentralBand(2));
        catch
            keyboard;
        end
        XYmaxProjection=max(Wave1,[],3);
        
        CenterOfMassMethod='VoxelDistribution';
        if strcmp(CenterOfMassMethod,'IntensityMax')% center of mass based on intensitymax of 25% highest voxels
            % first for X
            IntensityProfile=sumdims(PlaqueChPl(:,:,CentralBand(1):CentralBand(2)),[2,3]);
            [Wave1,Wave2]=sort(IntensityProfile);
            Wave1=round(size(IntensityProfile,1)/4); % choose 25% brightest slices
            PixCenter(1,1)=round(mean(Wave2(end-Wave1:end)));
            
            % then in Y
            IntensityProfile=sumdims(PlaqueChPl(:,:,CentralBand(1):CentralBand(2)),[1,3]);
            [Wave1,Wave2]=sort(IntensityProfile);
            Wave1=round(size(IntensityProfile,1)/4); % choose 25% brightest slices
            PixCenter(2,1)=round(mean(Wave2(end-Wave1:end)));
        elseif strcmp(CenterOfMassMethod,'VoxelDistribution')
            %         Wave3=ceil(size(IntensityProfile,1)*15/100); % choose 25%
            Wave1=sum(XYmaxProjection,2);
            Wave2=find(Wave1==max(Wave1(:)));
            PixCenter(1,1)=round(mean(Wave2(:)));
            
            Wave1=sum(XYmaxProjection,1);
            Wave2=find(Wave1==max(Wave1(:)));
            PixCenter(2,1)=round(mean(Wave2(:)));
        end
        
        PlaqueData.Data{Pl,1}.PixCenter(Time,1)={PixCenter};
        PlaqueData.Data{Pl,1}.UmCenter(Time,1)={(PixCenter-1).*Res+Fileinfo.UmStart{1}};
        %% determine total extension of plaque using RealPlaquesTotal
        PlaqueMask=uint8(RealPlaquesTotal(:,:,:,Time)==Pl);
        
        % determine border touching
        StackOutZProfile=permute(StackOut(PixCenter(1),PixCenter(2),:),[3,2,1]);
        DistanceCenter2TopBottom=sum(StackOutZProfile(PixCenter(3):end));
        DistanceCenter2TopBottom(2,1)=sum(StackOutZProfile(1:PixCenter(3)));
        DistanceCenter2TopBottom=DistanceCenter2TopBottom.*Res(3);
        PlaqueData.Data{Pl,1}.DistanceCenter2TopBottom(Time,1:2)=DistanceCenter2TopBottom.';
        BorderTouch=0;
        if min(DistanceCenter2TopBottom)<6
            BorderTouch=1;
        else
            Wave1=PlaqueMask(:,:,CentralBand(1):CentralBand(2));
            CentralChunk=zeros(size(Wave1,1)+2,size(Wave1,2)+2,size(Wave1,3),'uint8');
            CentralChunk(2:end-1,2:end-1,:)=Wave1;
            Wave1=imdilate(CentralChunk,ones(3,3));
            Wave2=StackOut(:,:,CentralBand(1):CentralBand(2));
            Wave3=Wave2(Wave1==1);
            if min(Wave3(:))==0
                BorderTouch=2;
            end
        end
        
        PlaqueData.Data{Pl,1}.BorderTouch(Time,1)=BorderTouch;
        Wave1=PlaqueMask(:,:,CentralBand(1):CentralBand(2));
        XYmaxProjection=max(Wave1,[],3);
        
        % radius whole area
        XYArea=sum(XYmaxProjection(:));
        RadiusArea(1)=(XYArea/pi)^0.5*Res(1);
        PlaqueData.Data{Pl,1}.RadiusArea(Time,1)=RadiusArea;
        
        
        % select optimal radius
        Radius=RadiusArea;
        if BorderTouch==3
            
            % radius uppper half
            Wave1=XYmaxProjection(1:PixCenter(1,1),:);
            XYArea=(sum(Wave1(:))-size(XYmaxProjection,2)/2)*2;
            RadiusHalfArea(1,1)=(XYArea/pi)^0.5*Res(1);
            % radius lower half
            Wave1=XYmaxProjection(PixCenter(1,1):end,:);
            XYArea=(sum(Wave1(:))-size(XYmaxProjection,2)/2)*2;
            RadiusHalfArea(1,2)=(XYArea/pi)^0.5*Res(1);
            % radius left half
            Wave1=XYmaxProjection(:,1:PixCenter(2,1));
            XYArea=(sum(Wave1(:))-size(XYmaxProjection,1)/2)*2;
            RadiusHalfArea(2,1)=(XYArea/pi)^0.5*Res(1);
            % radius right half
            Wave1=XYmaxProjection(:,PixCenter(2,1):end);
            XYArea=(sum(Wave1(:))-size(XYmaxProjection,1)/2)*2;
            RadiusHalfArea(2,2)=(XYArea/pi)^0.5*Res(1);
            
            PlaqueData.Data{Pl,1}.RadiusHalfArea(Time,1)={RadiusHalfArea};
            if max(BorderTouch(1:2,:))>-1
                keyboard; % plaque touches border
            end
            if BorderTouch(1,1)~=-1
                Radius=RadiusHalfArea(1,2);
                RadiusHalfArea(1,2)=NaN;
            end
            if BorderTouch(1,2)~=-1
                Radius=RadiusHalfArea(2,1);
                RadiusHalfArea(2,1)=NaN;
            end
            if BorderTouch(2,1)~=-1
                Radius=RadiusHalfArea(2,2);
                RadiusHalfArea(2,2)=NaN;
            end
            if BorderTouch(2,2)~=-1
                Radius=RadiusHalfArea(2,1);
                RadiusHalfArea(2,1)=NaN;
            end
            if isnan(Radius)
                keyboard; % Plaque is somewhere in the corner
            end
        end
        
        PlaqueData.Data{Pl,1}.Radius(Time,1)=Radius;
        if GhostPlaque==1
            PlaqueData.Data{Pl,1}.Radius(Time,1)=NaN;
        end
        
        %% implement roundation
        if exist('RoundationType')==1 && isempty(RoundationType)==0
            PlaqueMask=uint8(RealPlaquesTotal(:,:,:,Time)==Pl);
            PlaqueChPl=PlaqueCh.*PlaqueMask;
            [CutStart,CutEnd]=firstLastNonzero_4(PlaqueMask,'Total');
            CutStart(CutStart==-1)=1;
            CutEnd(CutEnd==-1)=Fileinfo.Pix{1}(CutEnd==-1);
            PlaqueMask=PlaqueMask(CutStart(1):CutEnd(1),CutStart(2):CutEnd(2),CutStart(3):CutEnd(3));
            PlaqueChPl=PlaqueChPl(CutStart(1):CutEnd(1),CutStart(2):CutEnd(2),CutStart(3):CutEnd(3));
            try; PlaqueChPl=uint8(smooth3(PlaqueChPl,'box',3)); end; % try because some plaques smaller than 3
            PlaqueMask=plaqueRoundation_2(PlaqueMask,PixCenter,CutStart,Res,Radius,PlaqueChPl);
            PlaqueMapCorr(CutStart(1):CutEnd(1),CutStart(2):CutEnd(2),CutStart(3):CutEnd(3))=PlaqueMapCorr(CutStart(1):CutEnd(1),CutStart(2):CutEnd(2),CutStart(3):CutEnd(3))+PlaqueMask*Pl;
%             Wave1=find(PlaqueMapCorr(:)==27);
%             if size(Wave1,1)>1
%                 keyboard;
%             end
        end
    end
    if exist('RoundationType')==1 && isempty(RoundationType)==0
        PlaqueMapTotal(:,:,:,Time)=PlaqueMapCorr;
    end
end
PlaqueData(cellfun(@isempty,PlaqueData.Data),:)=[]; % from PlaqueData remove all rows with empty .Data
cprintf('text',[' Clock: ',datestr(datenum(now),'mmm.dd HH:MM'),'\n']);



