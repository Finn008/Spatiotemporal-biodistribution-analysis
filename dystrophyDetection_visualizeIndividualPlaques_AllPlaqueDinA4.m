function dystrophyDetection_visualizeIndividualPlaques_AllPlaqueDinA4(PlaqueListSingle,MouseIds,MouseInfo,TargetFolder,Version)
global W;
% 20cm versus 30cm
ImageRowsCols=[6;10];ImageNumber=prod(ImageRowsCols);
for Mouse=1:size(MouseIds,1)
    MouseId=MouseIds(Mouse);
    PlaqueListSingle2=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & PlaqueListSingle.BorderTouch==0 & isempty_2(PlaqueListSingle.UmCenter)==0,:);
    PlaqueListSingle2=sortrows(PlaqueListSingle2,'PlaqueRadius','ascend');
    Pages=ceil(size(PlaqueListSingle2,1)/ImageNumber);
    for Ver=1:size(Version,1)
        VerId=Version(Ver);
        for m=1:size(PlaqueListSingle2,1)
            if ceil((m-1)/ImageNumber)==(m-1)/ImageNumber
                ChannelInfo2=PlaqueListSingle2.ImageGenerator{m,Ver};
                continue;
            end
            for n=1:size(ChannelInfo2,1)
%                 keyboard; % white edge
                Wave1=PlaqueListSingle2.ImageGenerator{m,Ver}.IntensityData{n,1}; Wave1(:,[1,end])=65535; Wave1([1,end],:)=65535;
                ChannelInfo2.IntensityData(n,1)={[ChannelInfo2.IntensityData{n,1};Wave1]};
                try
                    Wave1=PlaqueListSingle2.ImageGenerator{m,Ver}.ColorData{n,1}; Wave1(:,[1,end])=65535; Wave1([1,end],:)=65535;
                    ChannelInfo2.ColorData(n,1)={[ChannelInfo2.ColorData{n,1};Wave1]};
                end
            end
            if ceil(m/ImageNumber)==m/ImageNumber || m==size(PlaqueListSingle2,1)
                for n=1:size(ChannelInfo2,1)
                    ChannelInfo2.IntensityData(n,1)={flip(reshape_ImageBlocks_3(ChannelInfo2.IntensityData{n,1},ImageRowsCols(1)),2)};
                    try; ChannelInfo2.ColorData(n,1)={flip(reshape_ImageBlocks_3(ChannelInfo2.ColorData{n,1},ImageRowsCols(1)),2)}; end;
                end
                FilenameTotal=[PlaqueListSingle2.TreatmentType{1,1},'_M',num2str(MouseId),'_Age',num2str(round(MouseInfo.Age(MouseInfo.MouseId==MouseId))),'_Page',num2str(ceil(m/ImageNumber)),'_Version',num2str(VerId)];
%                 FilenameTotal=[PlaqueListSingle3.TreatmentType{Pl,1},'_M',num2str(MouseId),'_Pl',num2str(Pl),'_Time',num2str(TimeId),'_',PlaqueListSingle3.Filename{Pl,1},'_Version',num2str(VerId)];
                Path2file=[W.G.PathOut,'\ImageGenerator\',TargetFolder,'\DinA4_1\'];
                mkdir(Path2file);
                Path2file=[Path2file,FilenameTotal,'.jpg'];
                imageGenerator_2(ChannelInfo2,Path2file,[],struct('Rotate',-90));
            end
        end
        
        
    end
end