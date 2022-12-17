% Relationship: 1-everything else, 2-besides plaque, 3-above plaque, 4-below Plaque, 5-Blood
function [Co]=extractDistRelation_2(II,Res,ExcludeRoiIds)
global W;
if isstruct(II); v2struct(II); else; ReadOuts=II; end;

if exist('FilenameTotalFusedStack')==1; GenerateFusedStack=1; else; GenerateFusedStack=0; end;
cprintf('text','extractDistRelation: ');

MaskInfo=ReadOuts(strfind1(ReadOuts.CalcType,'Mask'),:);
ReadOuts=ReadOuts(strfind1(ReadOuts.CalcType,'Data'),:);

% load masks
for m=1:size(MaskInfo,1)
    Wave1=MaskInfo.ApplyD2D{m};
    if isstruct(Wave1)==1
        MaskData{m,1}=applyDrift2Data_4(Wave1,MaskInfo.ChannelName{m,1});
    elseif ischar(Wave1)
        MaskData{m,1}=im2Matlab_3(Wave1,MaskInfo.ChannelName{m,1});
    elseif isnumeric(Wave1)
        MaskData{m,1}=Wave1;
    end
    clear Wave1;
    if GenerateFusedStack==1
        if m==1
            J=struct;
            J.PixMax=size(MaskData{m,1}).';
            J.UmMinMax=[-J.PixMax.*Res/2,J.PixMax.*Res/2];
            J.Path2file=W.PathImarisSample;
            Application=openImaris_2(J);
            Application.FileSave(getPathRaw(FilenameTotalFusedStack),'writer="Imaris5"');
            quitImaris(Application); clear Application;
        end
        
        ex2Imaris_2(MaskData{m,1},FilenameTotalFusedStack,MaskInfo.Name{m,1});
    end
end

Pix=size(MaskData{1,1}).';
if exist('ExcludeRoiIds')~=1
    ExcludeRoiIds=repmat({[0]},[size(MaskNames,1)]);
end
if istable(ReadOuts)==0
    Wave1=ReadOuts;
    ReadOuts=table;
    ReadOuts.Name=Wave1(:,1);
    ReadOuts.Identity=cell2mat(Wave1(:,2));
end

Co=struct;
DistRelation=table; % plaques in rows
Co.PlaqueIDs=unique(MaskData{strfind1(MaskInfo.Name,'Membership'),1}(:));
Co.PlaqueIDs(Co.PlaqueIDs==0)=[];
Co.Res3D=prod(Res);

for iRead=1:size(ReadOuts,1)
    cprintf('text',[ReadOuts.Name{iRead,1},',']);
    if strcmp(ReadOuts.Identity(iRead,1),'Channel')
        Wave1=ReadOuts.ApplyD2D{iRead};
        if isstruct(Wave1)==1
            Wave1.Tpix=Pix;
            Data=applyDrift2Data_4(Wave1,ReadOuts.ChannelName{iRead,1});
        elseif ischar(Wave1)
            Data=im2Matlab_3(Wave1,ReadOuts.ChannelName{iRead,1});
        elseif isnumeric(Wave1) || islogical(Wave1)
            Data=Wave1;
        end
        clear Wave1;
        if GenerateFusedStack==1
            ex2Imaris_2(Data,FilenameTotalFusedStack,ReadOuts.Name{iRead,1});
        end
    elseif strcmp(ReadOuts.Identity(iRead,1),'SpotXYZR')
        keyboard;
        [Statistics]=im2Matlab_3(FilenameTotal,ReadOuts.Name{iRead,1},1,'Spot');
        keyboard;
        [Wave1]=umXYZ2pixXYZ(Statistics{:,{'PositionX','PositionY','PositionZ'}},Fileinfo.UmStart{1}.',Fileinfo.UmEnd{1}.',Fileinfo.Pix{1}.');
        
        XYZind=Statistics{:,{'PositionX','PositionY','PositionZ'}};
        XYZind=XYZind-repmat(Fileinfo.UmStart{1}.',[size(Statistics,1),1]);
        XYZind=XYZind./repmat(Fileinfo.Res{1}.',[size(Statistics,1),1]);
        XYZind=uint16(XYZind);
        XYZind(XYZind==0)=1;
        for m=1:3
            Wave2=repmat(Fileinfo.Pix{1}(m).',[size(Statistics,1),1]);
            Wave3=XYZind(:,m);
            Wave3(Wave3>Wave2)=Fileinfo.Pix{1}(m);
            XYZind(:,m)=Wave3;
        end
        XYZind=sub2ind(size(DistInOut),XYZind(:,1),XYZind(:,2),XYZind(:,3));
        Statistics.XYZind=XYZind;
        Statistics.DistInOut=DistInOut(XYZind);
        Statistics.Membership=Membership(XYZind);
        Statistics.Relationship=SubRegion(XYZind);
        
        Wave1=struct; Wave1.ObjInfo=Statistics;
        Statistics=Wave1;
        Path=['Co.Statistics.',ReadOuts.Name{iRead,1},'=Statistics;'];
        eval(Path);
        
        continue;
    elseif strcmp(ReadOuts.Identity(iRead,1),'SurfaceChannel')
        keyboard;
        if exist('Application')~=1
            Application=openImaris_2(Path2file);
        end
        [Data]=im2Matlab_3(Application,ReadOuts.Name{iRead,1},1,'Surface');
    elseif strcmp(ReadOuts.Identity(iRead,1),'StatisticsStorage')
        FilenameTotal=ReadOuts.ApplyD2D{iRead}.FilenameTotal;
        Fileinfo=getFileinfo_2(FilenameTotal);
        Path=[FilenameTotal,'_Statistics',ReadOuts.ChannelName{iRead,1},'.mat'];
        Path=getPathRaw(Path);
        Statistics=load(Path);
        Statistics=Statistics.Statistics;
        if isstruct(Statistics)==0
            Statistics=struct('ObjInfo',Statistics);
        end
        
        if strfind1(Statistics.ObjInfo.Properties.VariableNames.','PixXYZ') % if Spots
            try; Rotate=ReadOuts.ApplyD2D{iRead,1}.Rotate; catch; Rotate=[]; end;
            [~,Statistics.ObjInfo.PixXYZ,Statistics.ObjInfo.Ind]=umXYZ2pixXYZ(Statistics.ObjInfo{:,{'PositionX','PositionY','PositionZ'}},Fileinfo.UmStart{1}.',Fileinfo.UmEnd{1}.',Pix.',Rotate);
            Statistics.ObjInfo.DistInOut=MaskData{1}(Statistics.ObjInfo.Ind);
            Statistics.ObjInfo.Membership=MaskData{2}(Statistics.ObjInfo.Ind);
            Statistics.ObjInfo.Relationship=MaskData{3}(Statistics.ObjInfo.Ind);
        end
        
        Path=['Co.Statistics.',ReadOuts.Name{iRead,1},'=Statistics;'];
        eval(Path);
        if GenerateFusedStack==1
            Wave1=zeros(Pix.','uint8');
            Wave1(Statistics.ObjInfo.Ind)=Statistics.ObjInfo.RadiusX*200; % Diameter µm/100
            ex2Imaris_2(Wave1,FilenameTotalFusedStack,ReadOuts.Name{iRead,1});
            clear Wave1;
        end
        continue;
    elseif strcmp(ReadOuts.Identity(iRead,1),'StatisticsRefresh')
        keyboard;
        if exist('Application')~=1
            Application=openImaris_2(Path2file);
        end
        [Vobject,A2,PlaqueList]=selectObject(Application,ReadOuts.Name{iRead,1});
        [Statistics]=getObjectInfo_2(Vobject,[],Application);
        if isempty(Statistics)
            continue;
        end
        Path=['Co.Statistics.',ReadOuts.Name{iRead,1},'=Statistics;'];
        eval(Path);
        continue;
    end
    
    if max(Data(:))<=255 && strcmp(class(Data),'uint16')
        Data=uint8(Data);
    end
    
    if strcmp(ReadOuts.Identity(iRead,1),'Surface2D')
        keyboard;
        IncludedSlices=permute(max(max(Data,[],1),[],2),[3,2,1]);
        IncludedSlices=find(IncludedSlices==1);
        % for each slice set Memberships that have not Dystrophy at all to zero
        SubRegionSlices=uint8(SubRegion(:,:,IncludedSlices));
        DistInOutSlices=uint8(DistInOut(:,:,IncludedSlices));
        MembershipSlices=uint8(Membership(:,:,IncludedSlices));
        DataSlices=uint8(Data(:,:,IncludedSlices));
        for m=1:size(IncludedSlices,1)
            CurrentMembershipSlice=MembershipSlices(:,:,m);
            Wave1=unique(uint8(DataSlices(:,:,m)).*CurrentMembershipSlice);
            Wave2=unique(CurrentMembershipSlice);
            for m3=1:size(Wave1,1)
                Wave2(Wave2==Wave1(m3,1))=[];
            end
            for m3=1:size(Wave2,1)
                CurrentMembershipSlice(CurrentMembershipSlice==Wave2(m3,1))=0;
            end
            MembershipSlices(:,:,m)=CurrentMembershipSlice;
        end
        Out=Summer_3({Data(:,:,IncludedSlices)},{DistInOutSlices,MembershipSlices,SubRegionSlices},ExcludeRoiIds);
    else
%         Out=Summer_3({Data},{MaskData{1},MaskData{2},MaskData{3}},ExcludeRoiIds);
        Out=Summer_3({Data},MaskData.',ExcludeRoiIds);
    end
    SubRegionNumber=size(Out.RoiIds{3,1},1);
    PlaqueNumber=size(Out.SumRes,2);
%     keyboard;
    for Pl=1:PlaqueNumber
        PlID=num2str(Out.RoiIds{2,1}(Pl,1));
        if strfind1(DistRelation.Properties.RowNames,PlID)==0
            DistRelation.Data(PlID,1:SubRegionNumber)=repmat({table},[1,SubRegionNumber]);
        end
        DistRelation.RoiId(PlID,1)=Out.RoiIds{2,1}(Pl,1);
        for Sub=1:SubRegionNumber
            if size(Out.NumRes,1)==0; continue; end;
            Distance=(Out.MinMax(1,1):Out.MinMax(1,2)).'-50;
            DistRelation.Data{PlID,Sub}{num2strArray(Distance),'Distance'}=Distance;
            Volume=Out.NumRes(:,Pl,Sub);
            Data=Out.SumRes(:,Pl,Sub);
            if strcmp(ReadOuts.Identity(iRead,1),'Surface2D')
                Data=[Volume,Data];
            else
                DistRelation.Data{PlID,Sub}{num2strArray(Distance),'Volume'}=Volume;
            end
            DistRelation.Data{PlID,Sub}{num2strArray(Distance),ReadOuts.Name{iRead,1}}=Data;
            DistRelation.Data{PlID,Sub}=sortrows(DistRelation.Data{PlID,Sub},'Distance');
        end
    end
end
% pool the data
if exist('PoolSubRegions')==1
    for Sub=1:size(PoolSubRegions,2)
        DistRelation.Data2(:,Sub)=DistRelation.Data(:,PoolSubRegions{1,Sub}(1,1));
        for Pl=1:size(DistRelation,1)
            
            for m=2:size(PoolSubRegions{1,Sub},1)
                Columns=DistRelation.Data{Pl,PoolSubRegions{1,Sub}(m,1)}.Properties.VariableNames.';
                Columns(strfind1(Columns,'Distance'),:)=[];
                for Col=Columns.'
                    Wave1=DistRelation.Data2{Pl,Sub}{:,Col};
                    Wave2=DistRelation.Data{Pl,PoolSubRegions{1,Sub}(m,1)}{:,Col};
                    DistRelation.Data2{Pl,Sub}{:,Col}=Wave1+Wave2;
                end
            end
        end
    end
    DistRelation(:,'Data') = [];
    DistRelation.Data=DistRelation.Data2;
    DistRelation(:,'Data2') = [];
end

if exist('Application')==1
    quitImaris(Application);
    clear Application;
end
Co.DistRelation=DistRelation;
cprintf('text','\n');