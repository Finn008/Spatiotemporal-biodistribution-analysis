function comparePercentiles(FilenamePart)
global W;

FileList=strfind1(W.G.Fileinfo.FilenameTotal,FilenamePart);
FileList=W.G.Fileinfo(FileList,:);

for m1=1:size(FileList,1)
    DepthInfo=FileList.Results{m1,1}.DepthInfo;
    for m2=1:2
        Data(:,m1,m2)=table2array(DepthInfo.Percentiles{m2,1});
    end
end

Channel1=Data(:,:,1);
Channel2=Data(:,:,2);


NormData=Data./repmat(Data(70,:,:),[size(Data,1),1,1]);

SavePath=[W.G.PathOut,'\Unsorted\',FilenamePart];
J=struct;
J.Tit=strcat({'Timepoint: '},cellstr(num2str([1:size(Data,2)].')));
J.Frequency=2;
J.X=1:size(Data,1).';
J.OrigType=3;
J.Xlab='Percentile';
J.Ylab='Intensity [a.u.]';
J.Layout='black';

J.OrigYaxis=[   {NormData(:,:,1)},{'c.'};... % channel 1 corrected for laser adjustment
                {NormData(:,:,2)},{'r.'};... % channel 2 corrected for laser adjustment
    ];
J.Path=[SavePath,'.avi'];
movieBuilder_4(J);



J.OrigYaxis=[   {Data(:,:,1)},{'c.'};... % channel 1 corrected for laser adjustment
                {Data(:,:,2)},{'r.'};... % channel 2 corrected for laser adjustment
% J.Path=[SavePath,'Raw.avi'];
% movieBuilder_4(J);