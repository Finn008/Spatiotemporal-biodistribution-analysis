function shuffleData()

SourcePath='C:\Users\n4y\OneDrive - med.uni-muenchen.de\Shift data\Xray';
TargetPath='\\fs-mu.dzne.de\petersf\Raw data\Xray\ShuffleData';

for m=1:999999999999999999
    InputFiles=listAllFiles(SourcePath);
    if size(InputFiles,1)>0
        for File=1:size(InputFiles,1)
            movefile(InputFiles.Path2file{File},TargetPath,'f');
        end
    end
    pause(10);
end