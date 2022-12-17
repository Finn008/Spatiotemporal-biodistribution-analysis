function [Data3D,HistogramInfo]=percentiler(Data3D,Exclude,In)
try; v2struct(In); end;

if exist('HistogramInfo')~=1
    J=struct;
    try; J.ZumBin=Zres; end;
    try; J.Zres=Zres; end;
    [HistogramInfo]=getHistograms_3(J,Data3D,1-Exclude);
end

if exist('Zres')==1
    for m2=1:size(Data3D,3)
        [PercTable]=generatePercTable(DataOutput,HistogramInfo.PercentileProfile,[],m2);
        Data2D=Data3D(:,:,m2);
        Data2Dcopy=Data2D;
        Data2D(Data2Dcopy<=PercTable.SourceValue(1))=PercTable.TargetValue(1);
        for m3=2:size(PercTable,1)
            Data2D(Data2Dcopy<=PercTable.SourceValue(m3) & Data2Dcopy>PercTable.SourceValue(m3-1))=PercTable.TargetValue(m3);
        end
        Data3D(:,:,m2)=Data2D;
    end
else
    [PercTable]=generatePercTable(DataOutput,HistogramInfo.Percentiles);
    Data3Dcopy=Data3D;
    Data3Dcopy(Data3D<=PercTable.SourceValue(1))=PercTable.TargetValue(1);
    for n=2:size(PercTable,1)
        Data3Dcopy(Data3D<=PercTable.SourceValue(n) & Data3D>PercTable.SourceValue(n-1))=PercTable.TargetValue(n);
    end
    Data3D=Data3Dcopy;
    clear Data3Dcopy;
end

Data3D=uint8(Data3D);