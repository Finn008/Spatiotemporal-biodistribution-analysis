function [Data3D]=percentiler_2(Data3D,Exclude,PercTable,Zres)
% try; v2struct(In); end;


if strcmp(PercTable,'AllPercentiles')
    PercTable.Percentile=[(1:1:100),(99.1:0.1:99.9),(99.91:0.01:99.99),(99.991:0.001:99.999),(99.9991:0.0001:99.9999),(99.99991:0.00001:99.99999),(99.999991:0.000001:99.999999),(99.9999991:0.0000001:99.9999999),(99.99999991:0.00000001:99.99999999)].';
    PercTable.TargetValue(:,2)=1:size(PercTable,1);
end
if istable(PercTable)==0
    PercTable=array2table(PercTable,'VariableNames',{'Percentile','TargetValue'});
end



% if exist('HistogramInfo')~=1
%     J=struct;
%     try; J.ZumBin=Zres; end;
%     try; J.Zres=Zres; end;
%     [HistogramInfo]=getHistograms_3(J,Data3D,1-Exclude);
% end

if exist('Zres')==1
    for m2=1:Zres:size(Data3D,3)
%         [PercTable]=generatePercTable(DataOutput,HistogramInfo.PercentileProfile,[],m2);
        End=min(m2+Zres,size(Data3D,3));
        Data2D=Data3D(:,:,m2:End);
        PercTable.SourceValue=prctile_2(Data2D,PercTable.Percentile,Exclude(:,:,m2:End)==0);
        if isnan(PercTable.SourceValue(1)) % all voxels are excluded
            keyboard;
        end
        Data2Dcopy=Data2D;
        Data2D(Data2Dcopy<=PercTable.SourceValue(1))=PercTable.TargetValue(1);
        for m3=2:size(PercTable,1)
            Data2D(Data2Dcopy<=PercTable.SourceValue(m3) & Data2Dcopy>PercTable.SourceValue(m3-1))=PercTable.TargetValue(m3);
        end
        Data3D(:,:,m2:End)=Data2D;
    end
else
    keyboard;
    PercTable.SourceValue=prctile_2(Data3D,PercTable.Percentile,Exclude==0);
%     [PercTable]=generatePercTable(DataOutput,HistogramInfo.Percentiles);
    Data3Dcopy=Data3D;
    Data3Dcopy(Data3D<=PercTable.SourceValue(1))=PercTable.TargetValue(1);
    for n=2:size(PercTable,1)
        Data3Dcopy(Data3D<=PercTable.SourceValue(n) & Data3D>PercTable.SourceValue(n-1))=PercTable.TargetValue(n);
    end
    Data3D=Data3Dcopy;
    clear Data3Dcopy;
end

Data3D=uint8(Data3D);