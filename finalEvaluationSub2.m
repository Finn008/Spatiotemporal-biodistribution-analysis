function [SurfaceData]=finalEvaluationSub2(FileTypes,NameTable)
global W;
SurfaceData=struct;
OriginalSubCol=struct;
for Type=1:2
    for Time=1:size(FileTypes,1)
        SurfaceInfo=FileTypes.FA{Type,1}.RatioResults{Time,1}.Statistics;
        for Surf=fieldnames(SurfaceInfo).'
            Statistics=SurfaceInfo.(Surf{1});
            VariableNames=varName2Col(Statistics.ChannelNames);
            if isstruct(Statistics.ObjInfo)
                ObjInfo=struct2table(Statistics.ObjInfo);
            else
                ObjInfo=Statistics.ObjInfo;
            end
            ObjInfo.Membership=ObjInfo.IntensityCenter(:,VariableNames.Membership);
            ObjInfo.Distance=ObjInfo.IntensityCenter(:,VariableNames.DistInOut)-50;
            ObjInfo.Time(:)=Time;
            % remove everything with IntensityMin(DistInOut&Membershp) of zero
            ObjInfo(ObjInfo.IntensityMin(:,VariableNames.DistInOut)==0&ObjInfo.IntensityMin(:,VariableNames.Membership)==0,:)=[];
            
            if isfield(SurfaceData,Surf{1})
                [SurfaceData.(Surf{1}),OriginalSubCol.(Surf{1})]=fuseTable_4(SurfaceData.(Surf{1}),ObjInfo,[],{OriginalSubCol.(Surf{1}),Statistics.ChannelNames});
            else
                SurfaceData.(Surf{1})=ObjInfo;
                OriginalSubCol.(Surf{1})=Statistics.ChannelNames;
            end
        end
    end
end
% A1=1;
SavePath=[W.PathExp,'\output\Unsorted\'];
% SavePath=['\\Gnp42n\marvin\Finn\X0025\Analysis\output\Unsorted\'];
for Mod={'AutofluoSurface','Boutons1'}
    J=struct;
    if strfind1({'AutofluoSurface'},Mod,1)
        Diameter=SurfaceData.AutofluoSurface.Volume;
        Distance=SurfaceData.AutofluoSurface.Distance;
        Diameter=(Diameter*3/4/pi).^(1/3)*2;
        Resolution=0.2;
        Max=10;
        DisstributionYMax=8;
        ScatterYMax=5;
        MarkerSize=5;
    elseif strfind1({'Boutons1'},Mod,1)
        Diameter=SurfaceData.Boutons1.DiameterX;
        Distance=SurfaceData.Boutons1.Distance;
        Distance=Distance-0.5+rand(size(Distance,1),1);
        Resolution=0.02;
        Max=2;
        DisstributionYMax=5;
        ScatterYMax=1.5;
        MarkerSize=1;
    end
    
    
    MinReal=min(Diameter(:));
    MaxReal=max(Diameter(:));
    
    Histogram=round(Diameter/Resolution)*Resolution;
    Min=0;
    
    Histogram=histc(Histogram,Min:Resolution:Max);
    Histogram=Histogram/sum(Histogram(:))*100;
    Histogram=smoothn(Histogram,3,'Robust');

    %     J.Tit='Diameter distribution';
    J.X=(Min:Resolution:Max).';
    
    J.OrigYaxis=[...
        {Histogram},{'w-'};...
        ];
    J.OrigType=1;
    J.FontSize=30;
    J.AxisWidth=2;
    J.MarkerSize=2;
    J.LineWidth=2;
    J.Xlab='Diameter [µm]';
    J.Ylab='Occurrence [%]';
    J.Xrange=[Min;Max];
    J.Yrange=[0;DisstributionYMax];
    J.Layout='black';
    J.Path=[SavePath,NameTable{'Trace','Filename'}{1},',',Mod{1},'Distribution.png'];
    movieBuilder_4(J);
    
    % ScatterPlot
    
    J.X=Distance;
    J.Xrange=[0;100];
    J.Yrange=[0;ScatterYMax];
    J.Xlab='Distance [µm]';
    J.Ylab='Diameter [µm]';
    J.MarkerSize=MarkerSize;
    J.OrigYaxis=[...
        {Diameter},{'w.'};...
        ];
    J.Path=[SavePath,NameTable{'Trace','Filename'}{1},',',Mod{1},'Scatter.jpg'];
    movieBuilder_4(J);
end






