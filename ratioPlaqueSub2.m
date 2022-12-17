function [Relationship]=ratioPlaqueSub2(Timepoints,Membership,Fileinfo,DistInOut)


%% determine Plaque Relationship, 1 for everything else, 2 besides plaque, 3 above plaque
%     [Membership]=uint8(im2Matlab_2(Application,'Membership'));
%     [DistInOut]=uint8(im2Matlab_2(Application,'DistInOut'));
for Time=1:Timepoints
    DistInOutTp=DistInOut(:,:,:,Time);
    MembershipTp=Membership(:,:,:,Time);
    RelationshipTp=uint8(logical(MembershipTp));
    Pix=size(MembershipTp(:,:,:)).';
    Res=Fileinfo.Res{1};
    PlaqueIDMap=false(Pix.');
    PlaqueIDMap(DistInOutTp~=0&DistInOutTp<=50)=1; % inside plaque set to 1 everything else to 0
    LateralThickness=8;LateralThickness=round(LateralThickness/Res(3));
    
    PlaqueIDs=unique(MembershipTp(:));PlaqueIDs(PlaqueIDs==0)=[];
    
    for m=PlaqueIDs.'
        SubChunk=PlaqueIDMap; SubChunk(MembershipTp~=m)=0; SubChunk=logical(SubChunk);% inside plaque set to 1
        PlaqueMaxProjection=max(SubChunk,[],3);
%         PlaqueMaxProjection=uint8(1-PlaqueMaxProjection);
        MaxSlice=permute(sumdims(SubChunk,[1;2]),[3,2,1]);
        MaxSlice=round(mean(find(MaxSlice==max(MaxSlice(:)))));
        
        % below plaque =4
        Upper=MaxSlice-floor(LateralThickness/2);
        Lower=MaxSlice-round(30/Res(3));
        if Lower<1; Lower=1; end;
        if Upper>0
            SubChunk=repmat(PlaqueMaxProjection,[1,1,Upper-Lower+1]);
            SubChunk2=RelationshipTp(:,:,Lower:Upper);
            SubChunk2(SubChunk==1&MembershipTp(:,:,Lower:Upper)~=0)=4;
            RelationshipTp(:,:,Lower:Upper)=SubChunk2;
        end
        % above plaque =3
        Upper=Pix(3);
        Lower=MaxSlice;
        SubChunk=repmat(PlaqueMaxProjection,[1,1,Upper-Lower+1]);
        SubChunk2=RelationshipTp(:,:,Lower:Upper);
        SubChunk2(SubChunk==1&MembershipTp(:,:,Lower:Upper)==m&RelationshipTp(:,:,Lower:Upper)~=4)=3;
        RelationshipTp(:,:,Lower:Upper)=SubChunk2;
        
        % lateral to plaque=2
        Lower=MaxSlice-floor(LateralThickness/2)+1;
        Upper=Lower+LateralThickness-1;
        if Lower<1; Lower=1; end;
        if Upper>Pix(3); Upper=Pix(3); end;
        SubChunk=RelationshipTp(:,:,Lower:Upper);
        SubChunk(MembershipTp(:,:,Lower:Upper)==m&RelationshipTp(:,:,Lower:Upper)~=4)=2;
        RelationshipTp(:,:,Lower:Upper)=SubChunk;
        
        % plaque itself
        %         Relationship(Membership==m & DistInOut<=50)=Relationship(Membership==m & DistInOut<=50)+2;
    end
    Relationship(:,:,:,Time)=RelationshipTp;
end