function spotTracer()

Path='C:\Users\Admins\Desktop\Finns\Computer\Matlab\mfiles\Tracer\Example Data';

Deviation=[1;1;1];
Deviation(4,1)=sum(Deviation.^2)^0.5;

Data=xlsread(Path);
Data=array2table(Data,'VariableNames',{'Time','X','Y','Z','Id'});
Data.OrigPos=(1:size(Data,1)).';
% Ids=unique(Data.Id);


Times=unique(Data.Time);
for Time=Times(2:end).'
    Vectors=table;
    Selection1=Data(Data.Time==Time-1,:);
    Selection2=Data(Data.Time==Time,:);
    for m=1:size(Selection2,1)
        Xi=Selection1.X-Selection2.X(m);
        Yi=Selection1.Y-Selection2.Y(m);
        Zi=Selection1.Z-Selection2.Z(m);
        Wave1=(Xi.^2+Yi.^2+Zi.^2).^0.5;
        Data2add=table(Wave1,Xi,Yi,Zi,'VariableNames',{'XYZ','X','Y','Z'});
        Vectors=[Vectors;Data2add];
    end
    
    % binning
    Array=[Vectors.X,Vectors.Y,Vectors.Z,Vectors.XYZ];
    
    for m=1:4
        Ranges=(min(Array(:,m)):Deviation(m):max(Array(:,m))+Deviation(m)).';
        Histogram=histc(Array(:,m),Ranges);
%         figure; plot(Ranges,Histogram);
    end
    
    % put every vector in a 3D array, determine maximum intensity or local maximum
    
    
    
    
    Ranges=(0:Deviation(1):ceil(max(Vectors.X)/Deviation(1))*Deviation(1)).';
    HistogramX=histc(Vectors.X,Ranges);
    figure; plot(Ranges,HistogramX);
%     end
    
%     Vectors2=Vectors;
%     Vectors2.XYZ=round(Vectors.XYZ/XYZdeviation);
%     Vectors2.X=round(Vectors.X/Deviation(1));
%     Vectors2.Y=round(Vectors.Y/Deviation(2));
%     Vectors2.Z=round(Vectors.Z/Deviation(3));
%     
%     HistogramXYZ=histc(Vectors2.XYZ,(0:max(Vectors2.XYZ)));
    
    
    
    Wave1=linspace(0:XYZdeviation:max(Vectors.XYZ)).';
    
    A1=1;
end