% ChannelInfo.IntensityData provides intensity data, ChannelInfo.ColorData provides ColorId
function [Image4D]=imageGenerator_2(ChannelInfo,Path2file,BackgroundColor,Struct)
global ColorBlueprints;
if isempty(ColorBlueprints)
    ColorBlueprints=struct;
    global W;
    ColorPathXls=[W.PathProgs,'\ColormapMatlab.xlsx'];
    [~,Sheets]=xlsfinfo(ColorPathXls); Sheets=Sheets.';
    for m=1:size(Sheets,1)
        [~,~,Wave1]=xlsread(ColorPathXls,m);
        Wave1=array2table(Wave1(2:end,:),'VariableNames',Wave1(1,:));
        ColorBlueprints.(Sheets{m})=cell2mat(Wave1{:,{'R';'G';'B'}});
    end
end
if exist('Struct','Var')==1;v2struct(Struct);end;
Pix=size(ChannelInfo.IntensityData{1}).';
if exist('BackgroundColor','Var')==0 || isempty(BackgroundColor)
    BackgroundColor=[0;0;0];
end
Background=repmat(permute(BackgroundColor,[3,2,1]),Pix.');
if strfind1(ChannelInfo.Properties.VariableNames.','IntensityGamma')
    ChannelInfo.IntensityGamma(ChannelInfo.IntensityGamma==0,1)=1;
else
    ChannelInfo.IntensityGamma(:,1)=1;
end

if strfind1(ChannelInfo.Properties.VariableNames.','ColorGamma')
    ChannelInfo.ColorGamma(ChannelInfo.ColorGamma==0,1)=1;
else
    ChannelInfo.ColorGamma(:,1)=1;
end

for Ch=1:size(ChannelInfo,1)
    Colormap=ChannelInfo.Colormap{Ch,1}; % Colormap=jet(255);
    if isnumeric(Colormap) && size(Colormap,1)==3 && size(Colormap,2)==1
        Colormap=Colormap.';
    end
    if ischar(Colormap)
        if strcmp(Colormap,'Spectrum')
            Colormap=[linspace(0.5,0,28),linspace(0,0,113),linspace(0,1,58),linspace(1,1,57);...
                linspace(0,0,27),linspace(0,1,58),linspace(1,1,113),linspace(1,0,58);...
                linspace(1,1,84),linspace(1,0,58),linspace(0,0,114)].';
        elseif strcmp(Colormap,'Spectrum1') % lowest is black
            Colormap=[0,linspace(0.5,0,27),linspace(0,0,113),linspace(0,1,58),linspace(1,1,57);...
                0,linspace(0,0,26),linspace(0,1,58),linspace(1,1,113),linspace(1,0,58);...
                0,linspace(1,1,83),linspace(1,0,58),linspace(0,0,114)].';
        elseif strcmp(Colormap,'Spectrum2') % lowest is white
            Colormap=[1,linspace(0.5,0,27),linspace(0,0,113),linspace(0,1,58),linspace(1,1,57);...
                1,linspace(0,0,26),linspace(0,1,58),linspace(1,1,113),linspace(1,0,58);...
                1,linspace(1,1,83),linspace(1,0,58),linspace(0,0,114)].';
        elseif strcmp(Colormap,'Black2Blue2White')
            Colormap=[linspace(0,0,128),linspace(0,1,128);...
                linspace(0,1,256);...
                linspace(0,1,128),linspace(1,1,128)].';
        elseif strcmp(Colormap,'Random')
            Colormap=rand(65535,3); Colormap(1,:)=0;
        elseif strcmp(Colormap,'Random1')
            Colormap=rand(65535,3); Colormap(1,:)=1;
        elseif strcmp(Colormap,'RandomHeatmap')
            Colormap=[linspace(0.5,0,28*256),linspace(0,0,113*256),linspace(0,1,58*256),linspace(1,1,57*256);...
                linspace(0,0,27*256),linspace(0,1,58*256),linspace(1,1,113*256),linspace(1,0,58*256);...
                linspace(1,1,84*256),linspace(1,0,58*256),linspace(0,0,114*256)].';
            [~,Wave1]=sort(rand(65535,1));
            Colormap=Colormap(Wave1,:);
            Colormap(1,:)=1;
        else
            Colormap=ColorBlueprints.(Colormap);
        end
    end
    
    if size(Colormap,1)>1 && (strfind1(ChannelInfo.Properties.VariableNames.','ColorData',1)==0 || isempty(ChannelInfo.ColorData{Ch}))
        ChannelInfo.ColorData(Ch,1)=ChannelInfo.IntensityData(Ch,1);
        ChannelInfo.ColorMinMax(Ch,1)=ChannelInfo.IntensityMinMax(Ch,1);
        ChannelInfo.ColorGamma(Ch,1)=ChannelInfo.IntensityGamma(Ch,1);
        ChannelInfo.IntensityGamma(Ch,1)=1;
        ChannelInfo.IntensityData(Ch,1)={ones(size(ChannelInfo.IntensityData{Ch,1}))};
        ChannelInfo.IntensityMinMax(Ch,1)={[0;1]};
    end
    
    
    
    Image=ChannelInfo.IntensityData{Ch,1};
    if strfind1(ChannelInfo.Properties.VariableNames.','ImageAdjustment') && isempty(ChannelInfo.ImageAdjustment{Ch})==0
        if strcmp(ChannelInfo.ImageAdjustment{Ch},'PlaqueBorder')
            Wave1=Image>50 | Image==0;
            Wave2=imdilate(Wave1,ones(3,3,3));
            Image=Wave2-Wave1;
        end
    end
    %  normalize IntensityMinMax
    for m=1:2
        if m==1 && ischar(ChannelInfo.IntensityMinMax{Ch}) && strfind(ChannelInfo.IntensityMinMax{Ch},'Norm')
            Data2D=Image;
            String=ChannelInfo.IntensityMinMax{Ch};
        elseif m==2 && strfind1(ChannelInfo.Properties.VariableNames.','ColorMinMax') && ischar(ChannelInfo.ColorMinMax{Ch}) && strfind(ChannelInfo.ColorMinMax{Ch},'Norm')
            Data2D=ChannelInfo.ColorData{Ch,1};
            String=ChannelInfo.ColorMinMax{Ch};
        else
            continue
        end
        
        if strfind(String,'Center')
            Percentile=str2num(String(strfind(String,'Norm')+4:strfind(String,'Center')-1));
            Percentage=str2num(String(strfind(String,'Center')+6:end));
            EdgeLength=(Pix.^2*Percentage/100).^0.5;
            MinMax=round([Pix/2-EdgeLength/2,Pix/2+EdgeLength/2]);
            Data2D=Data2D(MinMax(1,1):MinMax(1,2),MinMax(2,1):MinMax(2,2));
        else
            Percentile=str2num(String(strfind(String,'Norm')+4:end));
        end
        if max(Data2D(:))==0
            Wave1=[0;1];
        else
            Wave1=double([0;max([prctile(Data2D(Data2D~=0),Percentile);1])]); % value should be at least 1 else cannot perform imadjust
        end
        if m==1
            ChannelInfo.IntensityMinMax{Ch}=Wave1;
        elseif m==2
            ChannelInfo.ColorMinMax{Ch}=Wave1;
        end
    end

    Image=imadjust(double(Image)/65535,[ChannelInfo.IntensityMinMax{Ch}.'/65535],[0,1],ChannelInfo.IntensityGamma(Ch));
    
    try; ColorData=[]; ColorData=ChannelInfo.ColorData{Ch}; end;
    if isempty(ColorData); ColorData=ones(size(Image)); end;
    if strfind1(ChannelInfo.Properties.VariableNames.','ColorMinMax') && isempty(ChannelInfo.ColorMinMax{Ch})==0
        ColorData=imadjust(double(ColorData)/65535 , [ChannelInfo.ColorMinMax{Ch}.'/65535] , [0,1] , ChannelInfo.ColorGamma(Ch));
        ColorData=uint16(ColorData*(size(Colormap,1)-1)+1);
    end
    for m=1:3
        ImageRGB(:,:,m)=Background(:,:,m)-(Background(:,:,m)-reshape(Colormap(ColorData,m),[size(Image)])).*Image;
    end
    ChannelInfo.Image{Ch,1}=ImageRGB;
    if Ch==1
        Image4D=ImageRGB;
    else
        
        Image4D(:,:,:,Ch)=ImageRGB;
    end
    % % %     try
    % % %         Image=insertText(Image,[1,1],num2str(PlaqueListSingle3.Time2Treatment(Ind)),'FontSize',10,'BoxColor','w');
    % % %     end
end

for Col=1:3
    Color=permute(Image4D(:,:,Col,:),[1,2,4,3]);
    if isequal(BackgroundColor,[0;0;0])
        ImageFinal(:,:,Col)=max(Color,[],3);
    elseif isequal(BackgroundColor,[1;1;1])
        ImageFinal(:,:,Col)=min(Color,[],3);
    end
end
if exist('Rotate','Var')
    ImageFinal=imrotate(ImageFinal,-Rotate);
end

imwrite(ImageFinal,Path2file);
