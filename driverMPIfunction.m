function driverMPIfunction()
dbstop if error;
Path2Excel='\\gnp42n\marvin\Viktoria_Korzhova\ca data\MPIdriver.xlsx';
[~,~,Table]=xlsread(Path2Excel);

Table=array2table(Table(2:end,:),'VariableNames',Table(1,:));
Table.Status=cell2mat(Table.Status);

for Folder=1:size(Table,1)
    if Table.Status(Folder)==1
        cd(Table.Path2folder{Folder});
        VK_GetTimeSeries; % 3min
        close all;
        DataPathString=[Table.Path2folder{Folder},'\TimeSeries.mat'];
        RiseTime=0.2;
        DecayTime=0.5;
        SignalCriterium=3.5;
        absdF=0.1;
        Wave1=strfind(Table.Path2folder{Folder},'\');
        Wave1=Table.Path2folder{Folder}(Wave1(end)+1:end);
        WhiskerTrace=[Table.Path2folder{Folder},'\',Wave1,'_whiskers.xlsx'];
        try
            CaSignalFinder_MPItest_Petar(DataPathString, RiseTime, DecayTime, SignalCriterium,absdF,WhiskerTrace);
            Table.Status(Folder,1)=0;
        catch
            Table.Status(Folder,1)=2;
        end
        close all;
    end
end
Wave1=[Table.Properties.VariableNames;table2cell(Table)];
xlswrite(Path2Excel,Wave1);