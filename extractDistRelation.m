function [Co]=extractDistRelation(II)
global W;
v2struct(II);

cprintf('text','extractDistRelation: ');
[Fileinfo,Ind,Path2file]=getFileinfo_2(FilenameTotal);


if exist('Membership')~=1
    [Membership]=uint8(im2Matlab_3(FilenameTotal,'Membership'));
end
if exist('DistInOut')~=1
    [DistInOut]=uint8(im2Matlab_3(FilenameTotal,'DistInOut'));
end
if exist('SubRegion')~=1
    SubRegion=[];
else
    [SubRegion]=uint8(im2Matlab_3(FilenameTotal,SubRegion));
end
if exist('ExcludeRoiIds')~=1
    ExcludeRoiIds={[0],[0],[]};
end
if istable(ReadOuts)==0
    Wave1=ReadOuts;
    ReadOuts=table;
    ReadOuts.Name=Wave1(:,1);
    ReadOuts.Identity=cell2mat(Wave1(:,2));
end

if exist('Application')~=1 % && find(ReadOuts.Identity(:,1)==1)
    Application=openImaris_2(Path2file);
end

Co=struct;

DistRelation=table; % plaques in rows

Co.PlaqueIDs=unique(Membership(:));
Co.PlaqueIDs(Co.PlaqueIDs==0)=[];
Co.Res3D=prod(Fileinfo.Res{1});

for m2=1:size(ReadOuts)
    cprintf('text',[ReadOuts.Name{m2,1},',']);
    if ReadOuts.Identity(m2,1)==0 % Channels
        [Data]=im2Matlab_3(FilenameTotal,ReadOuts.Name{m2,1});
    elseif ReadOuts.Identity(m2,1)==2 % Spots
%         [Statistics]=getObjectinfoHDF(FilenameTotal,ReadOuts.Name{m2,1});
        [Statistics]=im2Matlab_3(FilenameTotal,ReadOuts.Name{m2,1},1,'Spot');
        
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
        Path=['Co.Statistics.',ReadOuts.Name{m2,1},'=Statistics;'];
        eval(Path);
        
        continue;
    else
        [Vobject,A2,PlaqueList]=selectObject(Application,ReadOuts.Name{m2,1});
        [Statistics]=getObjectInfo_2(Vobject,[],Application);
        if isempty(Statistics)
            continue;
        end
        Path=['Co.Statistics.',ReadOuts.Name{m2,1},'=Statistics;'];
        eval(Path);
        [Data]=im2Matlab_3(Application,ReadOuts.Name{m2,1},1,'Surface');
        quitImaris(Application);
        clear Application;
    end
    
    if max(Data(:))<=255 && strcmp(class(Data),'uint16')
        Data=uint8(Data);
    end
    
%     J=struct;
%     J.ExcludeRoiIds=ExcludeRoiIds;
    if ReadOuts.Identity(m2,1)==3 % 2D Surface
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
        Out=Summer_3({Data},{DistInOut,Membership,SubRegion},ExcludeRoiIds);
    end
    SubRegionNumber=size(Out.RoiIds{3,1},1);
    PlaqueNumber=size(Out.SumRes,2);
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
            if ReadOuts.Identity(m2,1)==3 % 2D Surface
                Data=[Volume,Data];
            else
                DistRelation.Data{PlID,Sub}{num2strArray(Distance),'Volume'}=Volume;
            end
            DistRelation.Data{PlID,Sub}{num2strArray(Distance),ReadOuts.Name{m2,1}}=Data;
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


Co.DistRelation=DistRelation;
cprintf('text','\n');