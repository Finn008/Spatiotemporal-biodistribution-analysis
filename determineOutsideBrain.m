% function determineOutsideBrain(MetBluePerc,MetRedPerc,FileinfoRatioB,FilenameTotalRatioB,PathRaw)
function determineOutsideBrain(Projection,Pix,PathRaw,FilenameTotalRatioB,Surface)
keyboard; % discontinued since 2016.02.18
% % % % % % % %     Res=FileinfoRatioB.Res{1};
% % % % % % % %     Um=FileinfoRatioB.Um{1};
% % % % % % % %     Pix=FileinfoRatioB.Pix{1};
% % % % % % % %     [Surface]=im2Matlab_3(FilenameTotalRatioB,'MetBluePerc');
% % % % % % % %     
% % % % % % % %     Surface=Surface>90;
% % % % % % % %     
% % % % % % % %     Surface=imerode(Surface,ones(7,7));
% % % % % % % %     BW=bwconncomp(Surface,6);
% % % % % % % %     Table=table;
% % % % % % % %     Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
% % % % % % % %     Table.IdxList=BW.PixelIdxList.';
% % % % % % % %     Table.Volume=Table.NumPix*prod(Res(1:3));
% % % % % % % %     
% % % % % % % %     
% % % % % % % %     Table=Table(Table.Volume>=1000,:);
% % % % % % % %     Surface=ones(Pix(1),Pix(2),Pix(3),'uint8');
% % % % % % % %     for m=1:size(Table,1)
% % % % % % % %         %     Surface(Table.IdxList{m})=uint8(Table.Volume(m)/100);
% % % % % % % %         Surface(Table.IdxList{m})=1+ceil(Table.Volume(m)/100);
% % % % % % % %     end
% % % % % % % %     
% % % % % % % %     [PlaneRaw]=find3D(Surface-1);
% % % % % % % %     
% % % % % % % %     Projection=table;
% % % % % % % %     [Range]=gridding3D(Pix,Res,[4;4]);
% % % % % % % %     for X=Range{1}.'
% % % % % % % %         for Y=Range{2}.'
% % % % % % % %             Ind=size(Projection,1)+1;
% % % % % % % %             Projection.X(Ind,1)=mean(X);
% % % % % % % %             Projection.Y(Ind,1)=mean(Y);
% % % % % % % %             Wave1=PlaneRaw(X(1):X(2),Y(1):Y(2));
% % % % % % % %             Projection.Z(Ind,1)=nanmax(Wave1(:));
% % % % % % % %             
% % % % % % % %         end
% % % % % % % %     end
% % % % % % % %     Projection(isnan(Projection.Z),:)=[];
% % % % % % % %     
% % % % % % % %     Projection.Weight=double(Projection.Z);
% % % % % % % %     
% % % % % % % %     Path=[W.G.PathOut,'\Unsorted\Outside_',FilenameTotalRatioB,'.avi'];
% % % % % % % %     J=struct('Table',Projection,'Type','Maxima','Span',0.5,'MoviePath',Path,'XYZsize',Pix);
% % % % % % % %     Curve=letCurtainFall(J);
% % % % % % % %     
% % % % % % % %     for X=1:Pix(1)
% % % % % % % %         for Y=1:Pix(2)
% % % % % % % %             Surface(X,Y,Curve(X,Y):end)=0;
% % % % % % % %         end
% % % % % % % %     end
% % % % % % % %     ex2Imaris_2(Surface,FilenameTotalRatioB,'Outside');
%     Application=openImaris_2(PathRaw);
%     Application.SetVisible(1);
%     imarisSaveHDFlock(Application,PathRaw);
%     Application=openImaris_2(PathRaw);Application.SetVisible(1);
    
% % % % % % % %     %% determine autofluo
% % % % % % % %     
% % % % % % % %     Surface=MetRedPerc>90;
% % % % % % % %     Surface=imerode(Surface,ones(3,3)); % 449
% % % % % % % %     BW=bwconncomp(Surface,6);
% % % % % % % %     
% % % % % % % %     Table=table;
% % % % % % % %     Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
% % % % % % % %     Table.IdxList=BW.PixelIdxList.';
% % % % % % % %     Table.Volume=Table.NumPix*prod(Res(1:3));
% % % % % % % %     Wave1=find(Table.Volume>=50&Table.Volume<=1000);
% % % % % % % %     Table=Table(Wave1,:);
% % % % % % % %     BW.PixelIdxList=BW.PixelIdxList(1,Wave1);
% % % % % % % %     BW.NumObjects=size(Wave1,1);
% % % % % % % %     Center=regionprops(BW,'Centroid');
% % % % % % % %     Center={Center.Centroid}.';
% % % % % % % %     for m=1:size(Table,1)
% % % % % % % %         Table.XYZpix(m,1:3)=Center{m,1};
% % % % % % % %         Table.XYZum(m,1:3)=Center{m,1}.*Res.';
% % % % % % % %     end
% % % % % % % %     
% % % % % % % %     Path=[W.G.PathOut,'\Unsorted\Outside2_',FilenameTotalRatioB{1},'.avi'];
% % % % % % % %     J=struct('XYZdata',Table.XYZum,'Type','MeshDensity','MeshDensity',20,'MoviePath',Path,'XYZsize',Um);
% % % % % % % %     Curve=letCurtainFall(J);

%% Version 2












close all;
return;
%%


Path=[W.G.PathOut,'\Unsorted\Outside_',FilenameTotalRatioB{1},'.bmp'];

%     print -depsc2 -painters test3.eps;
saveas(Fid(1),Path);





X=repmat((1:Pix(1)).',[1,Pix(2)]);
Y=repmat((1:Pix(1)),[Pix(1),1]);

Projection=table;
Projection.Raw=[reshape(X,[prod(Pix(1:2)),1]),reshape(Y,[prod(Pix(1:2)),1]),reshape(PlaneRaw,[prod(Pix(1:2)),1])];
Projection(find(Projection.Raw(:,3)==65535),:)=[];




for X=1:Pix(1)
    for Y=1:Pix(2)
        Projection.Raw(size(Projection,1)+1,1:3)=[X,Y,PlaneRaw(X,Y)];
    end
end


ex2Imaris_2(Surface,FilenameTotalRatioB,'Plaque');
Application=openImaris_2(PathRaw);
imarisSaveHDFlock(Application,PathRaw);
Application=openImaris_2(PathRaw);Application.SetVisible(1);
keyboard;

%% Version 1

%     [MetRed]=im2Matlab_3(FilenameTotalRatioB,'MetRed');

keyboard;
%%
Surface=MetRedPerc>90;
Surface=imerode(Surface,ones(3,3)); % 449
BW=bwconncomp(Surface,6);

Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res(1:3));
Wave1=find(Table.Volume>=50&Table.Volume<=1000);
Table=Table(Wave1,:);
BW.PixelIdxList=BW.PixelIdxList(1,Wave1);
BW.NumObjects=size(Wave1,1);
Center=regionprops(BW,'Centroid');
Center={Center.Centroid}.';
for m=1:size(Table,1)
    Table.XYZpix(m,1:3)=Center{m,1};
    Table.XYZum(m,1:3)=Center{m,1}.*Res.';
end
for m=1:size(Table,1)
    Wave1=sort(((Table.XYZum(:,1)-Table.XYZum(m,1)).^2+(Table.XYZum(:,2)-Table.XYZum(m,2)).^2+(Table.XYZum(:,3)-Table.XYZum(m,3)).^2).^0.5);
    Table.MinDist(m,1)=mean(Wave1(2:5));
end

%     Table=Table(Table.Area>200,:);
%     Surface=uint8(Surface);
%     Surface=zeros(Pix(1),Pix(2),Pix(3),'uint8');
%     for m=1:size(Table,1)
% %         Surface(Table.IdxList{m})=Table.MinDist(m);
%         Surface(Table.IdxList{m})=1;
%         %         Surface(Table.IdxList{m})=Table.Volume2(m);
%     end




SubPix=80;
SubPix=round(SubPix/Res(1));
NewSize=floor(Pix(1)/SubPix);
SubPix=Pix(1)/NewSize;

ZProfile=zeros(0,Pix(3));
ZProfileMetBlue=zeros(0,Pix(3));
Projection=table;
for X=1:NewSize
    for Y=1:NewSize
        X1=(X-1)*SubPix+1;
        X2=X*SubPix;
        Y1=(Y-1)*SubPix+1;
        Y2=Y*SubPix;
        Wave1=Surface(X1:X2,Y1:Y2,:);
        Wave1=permute(sum(sum(Wave1,1),2),[3,2,1]);
        Projection(size(Projection,1)+1,{'X','Y'})={X,Y};
        ZProfile(size(ZProfile,1)+1,:)=Wave1;
        
        Wave1=MetBlue(X1:X2,Y1:Y2,:);
        Wave1=permute(sum(sum(Wave1,1),2),[3,2,1]);
        ZProfileMetBlue(size(ZProfileMetBlue,1)+1,:)=Wave1;
    end
end
[Projection.MaxVal,Projection.MaxLoc]=max(ZProfile,[],2);

%     Wave1=mean(ZProfile,1); figure; plot(Wave1);
%     ZProfile=sum(sum(Surface,1),2); ZProfile=permute(ZProfile,[3,2,1]); figure; plot(ZProfile);

Smooth=table([1;1;1],{[];[];[]},'VariableNames',{'Power','Robust'});
[Wave1,Wave2]=ableitung_2(ZProfile.',[],Smooth);
[Wave1,Wave2]=ableitung_2(ZProfileMetBlue.',[],Smooth,1);

% Set up fittype and options.
ft = fittype( 'lowess' );
opts = fitoptions( 'Method', 'LowessFit' );
opts.Normalize = 'on';
opts.Robust = 'LAR';
opts.Span = 0.9;

% Fit model to data.
[fitresult,gof]=fit([Projection.X,Projection.Y],Projection.MaxLoc,ft,opts);
Curve=feval(fitresult,repmat(linspace(1,NewSize,NewSize).',[1,NewSize]),repmat(linspace(1,NewSize,NewSize),[NewSize,1]));


Selection=Table(Table.XYZpix(:,3)>min(Curve(:))-10,:);
%     x=Wave1.XYZpix(:,1);y=Wave1.XYZpix(:,2);z=Wave1.XYZpix(:,3);

%% Fit: 'untitled fit 1'.
%     [xData, yData, zData] = prepareSurfaceData( x, y, z );

%     % Set up fittype and options.
%     ft = fittype( 'lowess' );
%     opts = fitoptions( 'Method', 'LowessFit' );
%     opts.Normalize = 'on';
%     opts.Robust = 'LAR';
%     opts.Span = 0.9;

% Fit model to data.
[fitresult,gof]=fit([Selection.XYZpix(:,1),Selection.XYZpix(:,2)],Selection.XYZpix(:,3),ft,opts);

% Curve=feval(fitresult,repmat((1:Pix(1)).',[1,Pix(2)]),repmat((1:Pix(2)),[Pix(1),1]));
Curve=feval(fitresult,repmat(linspace(1,Pix(1),100).',[1,100]),repmat(linspace(1,Pix(2),100),[100,1]));
Curve=imresize(Curve,[Pix(1),Pix(2)],'bilinear');
% Curve=feval(fitresult,uint16(repmat((1:100).',[1,100])),uint16(repmat((1:100),[100,1])));
Curve=uint16(Curve);

Surface=zeros(Pix(1),Pix(2),Pix(3),'uint8');
for X=1:Pix(1)
    for Y=1:Pix(2)
        %             Surface(X,Y,Curve(X,Y):end)=1;
        Z1=Curve(X,Y)-1;
        Z2=Curve(X,Y)+1;
        Surface(X,Y,Z1:Z2)=1;
    end
end
Surface=Surface(:,:,1:Pix(3));


% Plot fit with data.
Fid=figure;
set(Fid,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
whitebg('white');
Fid=plot(fitresult,[Selection.XYZpix(:,1),Selection.XYZpix(:,2)],Selection.XYZpix(:,3));
xlabel x
ylabel y
zlabel z
set(Fid,'MarkerSize',2,'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor','k');
grid on
view(9.5,30.0);
Path=[W.G.PathOut,'\Unsorted\Outside_',FilenameTotalRatioB{1},'.bmp'];

%     print -depsc2 -painters test3.eps;
saveas(Fid(1),Path);
%
%     export_fig(Fid(1),Path);





    
    
    
    
    
    
    
    
    
    
    
    
    determineOutsideBrain(Projection,Pix,PathRaw,FilenameTotalRatioB,Surface);
    
    
    % Surface=zeros(Pix(1),Pix(2),Pix(3),'uint8');
    for X=1:Pix(1)
        for Y=1:Pix(2)
            Surface(X,Y,Curve(X,Y):end)=0;
            %         Z1=Curve(X,Y)-1;
            %         Z2=Curve(X,Y)+1;
            %         Surface(X,Y,Z1:Z2)=1;
        end
    end
    % Surface=Surface(:,:,1:Pix(3));
    
    ex2Imaris_2(Surface,FilenameTotalRatioB,'Outside');
    Application=openImaris_2(PathRaw);
    Application.SetVisible(1);
    imarisSaveHDFlock(Application,PathRaw);
    Application=openImaris_2(PathRaw);Application.SetVisible(1);
    
    
    
    
    %% area definition
    Surface=MetRedPerc>90;
    %     Surface(MetBlue>10)=0;
    Surface=imerode(Surface,ones(3,3)); % 449
    BW=bwconncomp(Surface,4);
    
    Res=FileinfoRatioB.Res{1};
    Um=FileinfoRatioB.Um{1};
    Pix=FileinfoRatioB.Pix{1};
    
    Table=table;
    Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    Table.IdxList=BW.PixelIdxList.';
    Table.Area=round(Table.NumPix*prod(Res(1:2)));
    Table.Area2=uint8(Table.Area);
    Table=Table(Table.Area2>=2,:);
    %     Table=Table(Table.Area>200,:);
    Surface=uint8(Surface);
    for m=1:size(Table,1)
        Surface(Table.IdxList{m})=Table.Area2(m);
    end
    
    ex2Imaris_2(Surface,FilenameTotalRatioB,'Surface');
    Application=openImaris_2(PathRaw);
    imarisSaveHDFlock(Application,PathRaw);
    Application=openImaris_2(PathRaw);Application.SetVisible(1);
    
    SubPix=10;
    SubPix=round(SubPix/Res(1));
    NewSize=floor(Pix(1)/SubPix);
    SubPix=Pix(1)/NewSize;
    clear MaxProjection;
    for X=1:NewSize
        for Y=1:NewSize
            X1=(X-1)*SubPix+1;
            X2=X*SubPix;
            Y1=(Y-1)*SubPix+1;
            Y2=Y*SubPix;
            Wave1=Surface(X1:X2,Y1:Y2,:);
            Wave1=permute(sum(sum(Wave1,1),2),[3,2,1]);
            
            %             [MaxValues,MaxLocs,MaxWidths,MaxProms] = findpeaksFinn(Wave1,'IncludeBoth');
            [~,Projection(X,Y)]=max(Wave1);
        end
    end
    ex2ex_2(Projection);
    
    
    ZProfile4=sum(sum(Surface,1),2); ZProfile4=permute(ZProfile4,[3,2,1]); figure; plot(ZProfile4);
    [~,A1]=max(ZProfile4)
    
    
    %%
    Surface=MetBlue>3;
    ZProfile=sum(sum(Surface,1),2); ZProfile=permute(ZProfile,[3,2,1]); figure; plot(ZProfile);
    
    %%
    Surface=MetRedPerc>90;
    Surface(MetBlue<3)=0;
    %     Surface=imerode(Surface,ones(2,2));
    ZProfile2=sum(sum(Surface,1),2); ZProfile2=permute(ZProfile2,[3,2,1]); figure; plot(ZProfile2);
    [~,A1]=max(ZProfile2)
    
    
    Surface=imdilate(Surface,ones(42,42,42));
    
    
    
    ex2Imaris_2(Surface,FilenameTotalRatioB,'Surface');
    
    Application=openImaris_2(PathRaw);
    imarisSaveHDFlock(Application,PathRaw);
    Application=openImaris_2(PathRaw);Application.SetVisible(1);
    %%
    %     Surface=BRratio>40;
    Surface=MetRed>40;
    Surface(MetBlue<3)=0;
    ZProfile=sum(sum(Surface,1),2); ZProfile=permute(ZProfile,[3,2,1]);
    
    
    imarisSaveHDFlock(Application,PathRaw);