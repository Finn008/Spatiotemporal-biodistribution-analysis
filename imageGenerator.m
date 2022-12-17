% ChannelInfo.IntensityData provides intensity data, ChannelInfo.ColorData provides ColorId
function [Image4D]=imageGenerator(ChannelInfo,Path2file)
VariableNames=ChannelInfo.Properties.VariableNames.';
for Ch=1:size(ChannelInfo,1)
    Image=ChannelInfo.IntensityData{Ch,1};
    if strfind1(VariableNames,'ImageAdjustment') && isempty(ChannelInfo.ImageAdjustment{Ch})==0
        if strcmp(ChannelInfo.ImageAdjustment{Ch},'PlaqueBorder')
            Wave1=Image>50 | Image==0;
            Wave2=imdilate(Wave1,ones(3,3,3));
            Image=Wave2-Wave1;
        end
    end
    if strfind1(VariableNames,'Colormap') && isempty(ChannelInfo.Colormap{Ch})==0
        if ischar(ChannelInfo.IntensityMinMax{Ch}) && strfind(ChannelInfo.IntensityMinMax{Ch},'Norm')
            ChannelInfo.IntensityMinMax{Ch}=[0;prctile(Image(:),str2num(ChannelInfo.IntensityMinMax{Ch}(5:end)))];
        end
        Image=double(Image)/65535;
        Image=imadjust(Image,[ChannelInfo.IntensityMinMax{Ch}.'/65535],[0,1],ChannelInfo.IntensityGamma(Ch));
        
        Colormap=ChannelInfo.Colormap{Ch,1}; % Colormap=jet(255);
        if isnumeric(Colormap) && size(Colormap,1)==3 && size(Colormap,2)==1
            Colormap=Colormap.';
        end
        if ischar(Colormap)
            if strcmp(Colormap,'Spectrum')
                Colormap=[linspace(0.5,0,28),linspace(0,0,113),linspace(0,1,58),linspace(1,1,57);...
                    linspace(0,0,27),linspace(0,1,58),linspace(1,1,113),linspace(1,0,58);...
                    linspace(1,1,84),linspace(1,0,58),linspace(0,0,114)].';
            elseif strcmp(Colormap,'Spectrum1')
                Colormap=[0,linspace(0.5,0,27),linspace(0,0,113),linspace(0,1,58),linspace(1,1,57);...
                    0,linspace(0,0,26),linspace(0,1,58),linspace(1,1,113),linspace(1,0,58);...
                    0,linspace(1,1,83),linspace(1,0,58),linspace(0,0,114)].';
            elseif strcmp(Colormap,'Spectrum2')
                Colormap=[1,linspace(0.5,0,27),linspace(0,0,113),linspace(0,1,58),linspace(1,1,57);...
                    1,linspace(0,0,26),linspace(0,1,58),linspace(1,1,113),linspace(1,0,58);...
                    1,linspace(1,1,83),linspace(1,0,58),linspace(0,0,114)].';
%             elseif strcmp(Colormap,'Spectrum2')
%                 Colormap=[0,1,linspace(0.5,0,27),linspace(0,0,112),linspace(0,1,58),linspace(1,1,57);...
%                     0,1,linspace(0,0,26),linspace(0,1,57),linspace(1,1,113),linspace(1,0,58);...
%                     0,1,linspace(1,1,83),linspace(1,0,57),linspace(0,0,114)].';
            elseif strcmp(Colormap,'Black2Blue2White')
                Colormap=[linspace(0,0,128),linspace(0,1,128);...
                    linspace(0,1,256);...
                    linspace(0,1,128),linspace(1,1,128)].';
            end
        end
        try; ColorData=[]; ColorData=ChannelInfo.ColorData{Ch}; end;
        if isempty(ColorData); ColorData=ones(size(Image)); end;
        if strfind1(VariableNames,'ColorMinMax') && isempty(ChannelInfo.ColorMinMax{Ch})==0
%             uint8(imadjust(double(ColorData)/256,[ChannelInfo.ColorMinMax{Ch}.'/256],[0,1])*256);
            ColorData=uint16(imadjust(double(ColorData)/256,[ChannelInfo.ColorMinMax{Ch}.'/256],[0,1])*255+1); % uint16 because otherwise the maximum color in line 256 is not reached
        end
        clear ImageRGB;
        ImageRGB=ones(size(Image,1),size(Image,2),3);
        for m=1:3
            ImageRGB(:,:,m)=Image.*reshape(Colormap(ColorData,m),[size(Image)]);
        end
        
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
%     ImageFinal(:,:,Col)=max(Color,[],3);
    ImageFinal(:,:,Col)=min(Color,[],3);
end
imwrite(ImageFinal,Path2file);
