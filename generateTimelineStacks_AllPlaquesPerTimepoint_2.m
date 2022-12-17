function generateTimelineStacks_AllPlaquesPerTimepoint_2(Mouse,MouseInfo,PlaqueListSingle)
global W;
ChannelInfo=table;
Version=4;
if Version==1
    ChannelInfo={'VglutGreen',D2DRatioA,{struct('Multiply',3)}};
    ImageIdentifier='VglutGreen';
elseif Version==2
    ChannelInfo={'Dystrophies2Radius','D2DRatioA',{struct('ColorTable','jet','MinMax',[0;30])}};
    ImageIdentifier='DystrophyMap';
elseif Version==3 % Dystrophies2Radius, Plaque size as circonference in white
    ChannelInfo={'Dystrophies2Radius','D2DRatioA',{struct('ColorTable','jet','MinMax',[0;30])};...
        'MetBlue','D2DRatioB',{struct('ColorTable',[1;1;1],'MinMax',[0;1])};...
        };
    ImageIdentifier='DystrophyMap&PlaqueBorder';
elseif Version==4 % Dystrophies2Radius, Methoxy-fluorescence
%     ChannelInfo={'Dystrophies2Radius','D2DRatioA',{struct('ColorTable','jet','MinMax',[0;30])};...
%         'MetBlue','D2DRatioB',{struct('ColorTable',[1;1;1],'MinMax',[0;1])};...
%         };
        ChannelInfo(1,{'Channel','D2D','Colormap','IntensityMinMax','IntensityGamma','ColorMinMax'})={'Dystrophies2Radius','D2DRatioA',{'Spectrum'},{[0;80]},1,{[0;60]}};
        ChannelInfo(2,{'Channel','D2D','Colormap','IntensityMinMax','IntensityGamma'})={'MetBlue','D2DRatioB',{[0,1,1]},{[0;80]},1};
        %ColorData and IntensityData
end
% ChannelInfo=array2table(ChannelInfo,'VariableNames',{'Channel','D2D','Settings'});

% Mouse=find(MouseInfo.MouseId==MouseId);

EdgeRadius=[20;20;0];

PlaqueListSingle2=PlaqueListSingle(PlaqueListSingle.MouseId==MouseInfo.MouseId(Mouse) & isempty_2(PlaqueListSingle.UmCenter)==0,:);

GlobalRes=[];
RoiInfo=MouseInfo.RoiInfo{Mouse,1};
for Roi=1:size(RoiInfo,1)
    RoiId=RoiInfo.Roi(Roi);
    Timepoints=unique(PlaqueListSingle2.Time2Treatment(PlaqueListSingle2.RoiId==floor(RoiId)));
    for Time=1:size(Timepoints,1)
        PlaqueListSingle3=PlaqueListSingle2(find(PlaqueListSingle2.Time2Treatment==Timepoints(Time) & PlaqueListSingle2.RoiId==floor(RoiId)),:);
        Filenames=MouseInfo.RoiInfo{Mouse,1}.Files{Roi,1}.Filenames;
        if size(Filenames,2)==1; continue; end;
        Filename=Filenames{PlaqueListSingle3.Time(1),2};
        if isempty(Filename); continue; end;
        [D2DDeFinAgreen,D2DDeFinAred,D2DRatioA,D2DRatioB,D2DTrace,FitCoefTrace2B,FitCoefB2A,Res,UmMinMax]=getRotationDrift(Filename,PlaqueListSingle3.Time(1),GlobalRes);
        if isempty(D2DDeFinAgreen);continue; end;
        if isempty(GlobalRes)
            GlobalRes=Res;
        end
        for Ch=1:size(ChannelInfo,1)
            ChannelInfo.Data(Ch,1)={applyDrift2Data_4(eval(ChannelInfo.D2D{Ch}),ChannelInfo.Channel{Ch})};
        end
        Pix=size(ChannelInfo.Data{Ch,1}).';
        for Pl=1:size(PlaqueListSingle3,1)
            PlId=PlaqueListSingle3.PlId(Pl);
            UmCenter=PlaqueListSingle3.UmCenter{Pl};
            
            [Wave1]=YofBinFnc(repmat(UmCenter(3),[3,1]),FitCoefTrace2B(:,1),FitCoefTrace2B(:,2),FitCoefTrace2B(:,3));
            PlXYZb=UmCenter+Wave1;
            [Wave1]=YofBinFnc(repmat(PlXYZb(3),[3,1]),FitCoefB2A(:,1),FitCoefB2A(:,2),FitCoefB2A(:,3));
            PlXYZa=PlXYZb+Wave1;
            ChunkUmMinMax=PlXYZa-EdgeRadius-UmMinMax(:,1);
            ChunkPixMinMax=round(ChunkUmMinMax./GlobalRes);
            ChunkPixMinMax(:,2)=ChunkPixMinMax+round(2*EdgeRadius./GlobalRes);
            ChunkPix=(ChunkPixMinMax(:,2)-ChunkPixMinMax(:,1)+1);
            Chunk=zeros(ChunkPix.','uint16');
            
            Ind=find(PlaqueListSingle2.Time2Treatment==Timepoints(Time) & PlaqueListSingle2.RoiId==floor(RoiId) & PlaqueListSingle2.PlId==PlId);
            for Ch=1:size(ChannelInfo,1)
                if max(ChunkPixMinMax(:,1)>Pix)==1 || max(ChunkPixMinMax(:,2)<1)==1
                    continue;
                end
                PixOutside=1-ChunkPixMinMax(:,1);
                PixOutside(:,2)=ChunkPixMinMax(:,2)-Pix;
                PixOutside(PixOutside<0)=0;
                ChunkPixMinMax(ChunkPixMinMax(:,1)<1,1)=1;
                ChunkPixMinMax(ChunkPixMinMax(:,2)>Pix,2)=Pix(ChunkPixMinMax(:,2)>Pix);
                PixInsert=[PixOutside(:,1)+1,ChunkPix-PixOutside(:,2)];
                Data3D=ChannelInfo.Data{Ch,1};
                Chunk(PixInsert(1,1):PixInsert(1,2),PixInsert(2,1):PixInsert(2,2),PixInsert(3,1):PixInsert(3,2))=Data3D(ChunkPixMinMax(1,1):ChunkPixMinMax(1,2),ChunkPixMinMax(2,1):ChunkPixMinMax(2,2),ChunkPixMinMax(3,1):ChunkPixMinMax(3,2));
                PlaqueListSingle2.ImageData(Ind,Ch)={Chunk};
                
            end
        end
    end
    disp(Mouse);
end
try
    ChannelInfo(:,'Data')=[];
catch
    return;
end

PlaqueListSingle3=PlaqueListSingle2(isempty_2(PlaqueListSingle2.ImageData)==0,:);

for Ind=1:size(PlaqueListSingle3,1)
    for Ch=1:size(ChannelInfo,1)
        Image=PlaqueListSingle3.ImageData{Ind,Ch};
        Settings=ChannelInfo.Settings{Ch}{1};
        if isempty(Settings)==0
            Fieldnames=fieldnames(Settings);
            if strfind1(Fieldnames,'Multiply')
                Image=Image*Settings.Multiply;
            elseif strfind1(Fieldnames,'ColorTable')
                Image=uint16(double(Image)*65535/Settings.MinMax(2));
                Colormap=jet(255);
                Colormap(1,:)=[0,0,0];
                Image=ind2rgb(gray2ind(Image,255),Colormap);
            end
        end
        try
            Image=insertText(Image,[1,1],num2str(PlaqueListSingle3.Time2Treatment(Ind)),'FontSize',10,'BoxColor','w');
        end
        PlaqueListSingle3.ImageFinal{Ind,1}=Image;
    end
end

% PlaqueIds=accumarray_8(PlaqueListSingle3(:,{'RoiId';'PlId'}),[],@nansum,[],'Sparse');
PlaqueIds=accumarray_9(PlaqueListSingle3(:,{'RoiId';'PlId'}),[],@nansum,[],'Sparse');
PlaqueNumber=size(PlaqueIds,1);
Timepoints=unique(PlaqueListSingle3.Time2Treatment);
Pix=size(PlaqueListSingle3.ImageData{1}).';

% put all plaques of one timepoint on one image
Path2file=[W.G.PathOut,'\OverviewImages\Timepoints\'];
ColNumber=ceil(PlaqueNumber^0.5);
for Time=1:size(Timepoints,1)
    clear Data;
    Selection=PlaqueListSingle3(find(PlaqueListSingle3.Time2Treatment==Timepoints(Time)),:);
    for Ind=1:size(Selection,1)
        PlId=find(PlaqueIds.RoiId==Selection.RoiId(Ind) & PlaqueIds.PlId==Selection.PlId(Ind));
        Row=ceil(PlId/ColNumber);
        Col=PlId-((Row-1)*ColNumber);
        Image=Selection.ImageFinal{Ind,Ch};
        Data((Row-1)*Pix(1)+1:(Row-1)*Pix(1)+Pix(1),(Col-1)*Pix(2)+1:(Col-1)*Pix(2)+Pix(2),1:size(Image,3))=Image;
    end
    Path=[Path2file,MouseInfo.TreatmentType{Mouse},'_M',num2str(MouseInfo.MouseId(Mouse)),'_',ImageIdentifier,'_Time',num2str(Time),',',num2str(Timepoints(Time)),'.tif'];
    imwrite(Data,Path);
end


% put all timepoints of one plaque per image
Path2file=[W.G.PathOut,'\OverviewImages\Plaques\'];
ColNumber=ceil(size(Timepoints,1)^0.5);
for Pl=1:size(PlaqueIds,1)
    clear Data;
    Selection=PlaqueListSingle3(find(PlaqueListSingle3.RoiId==PlaqueIds.RoiId(Pl) & PlaqueListSingle3.PlId==PlaqueIds.PlId(Pl)),:);
    for Ind=1:size(Selection,1)
        Row=ceil(Ind/ColNumber);
        Col=Ind-((Row-1)*ColNumber);
        Image=Selection.ImageFinal{Ind};
        Data((Row-1)*Pix(1)+1:(Row-1)*Pix(1)+Pix(1),(Col-1)*Pix(2)+1:(Col-1)*Pix(2)+Pix(2),1:size(Image,3))=Image;
    end
    Path=[Path2file,MouseInfo.TreatmentType{Mouse},'_M',num2str(MouseInfo.MouseId(Mouse)),'_',ImageIdentifier,'Roi',num2str(PlaqueIds.RoiId(Pl)),'Pl',num2str(PlaqueIds.PlId(Pl)),'.tif'];
    imwrite(Data,Path);
end