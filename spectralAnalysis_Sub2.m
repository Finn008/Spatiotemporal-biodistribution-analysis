function [ObjectInfo]=spectralAnalysis_Sub2(ObjectInfo);
global W;
SavePath=[W.PathExp,'\output\Unsorted\'];
Xaxis=ObjectInfo.Statistics{1}.ObjInfo.Spectrum{1}.Axis;

for Obj=1:size(ObjectInfo,1)
    ObjInfo=ObjectInfo.Statistics{Obj,1}.ObjInfo;
    ObjInfo2=ObjectInfo.Statistics{Obj,1}.ObjInfo2;

    % all spectra in one
    Data=ObjInfo2.NormMean{'Original'};
    J=struct;
%     J.Tit='Emission spectrum';
    J.X=Xaxis;
    J.OrigYaxis={Data};
    J.Sp='w-';
    J.Xlab='Wavelength [nm]';
    J.Ylab='Emission intensity [%]';
    J.Yrange=[0;103];
    J.Style=1;
    J.Path=[SavePath,ObjectInfo.Name{Obj},'_NormMean.eps'];
    movieBuilder_4(J);
    
    % Mean and its StdDev
    Wave1=ObjInfo2.NormMean{'Mean'}{:,:};
    Data2=[Wave1(:,1),Wave1(:,1)-Wave1(:,2),Wave1(:,1)+Wave1(:,2)];
    J.OrigYaxis={Data2(:,2),struct('Color',[0.3,0.3,0.3],'Area',1);Data2(:,3),[];Data2(:,1),'w-'};
    J.Path=[SavePath,ObjectInfo.Name{Obj},'_NormMean.StdDev.eps'];
    movieBuilder_4(J);
    
    % spectra one after the other
%     J.Tit=strcat({'Emission spectrum: '},num2strArray((1:size(Data,2)).'));
    J.OrigYaxis={Data};
    J.OrigType=3;
    J.Frequency=0.25;
    J.Path=[SavePath,ObjectInfo.Name{Obj},'_NormMean.avi'];
    movieBuilder_4(J);
    
    % all spectra cumulative
    J.Path=[SavePath,ObjectInfo.Name{Obj},'_NormMeanCum.avi'];
    J.Cumulative=1;
    movieBuilder_4(J);
   
end