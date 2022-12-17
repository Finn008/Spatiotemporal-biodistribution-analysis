function finalEvaluation_RecalculateDistance_2(MouseInfo,MouseInfoTime,PlaqueListSingle,NewBornPlaqueList)
% keyboard;
% % MouseInfoTime.TotalVolume2(:,1)=0;
% % MouseInfoTime.VolumeDistribution(:,1:256)=0;
Table=table;
for Mouse=1:size(MouseInfo,1)
    RoiInfo=MouseInfo.RoiInfo{Mouse,1};
    for Roi=1:size(RoiInfo,1)
        if floor(RoiInfo.Roi(Roi))==RoiInfo.Roi(Roi)
            Data2add=table;
            Data2add.Filename=RoiInfo.Files{Roi,1}.Filenames(:,1);
            Data2add.MouseId(:,1)=MouseInfo.MouseId(Mouse);
            Data2add.Mouse(:,1)=Mouse;
            Data2add.Age=RoiInfo.Files{Roi,1}.Age(:,1);
            Data2add.Roi(:,1)=RoiInfo.Roi(Roi);
            Data2add.StackB(:,1)=RoiInfo.StackB(Roi);
            Data2add.Time(:,1)=(1:size(Data2add,1)).';
            Table=[Table;Data2add];
        end
    end
end

disp('RecalculateDistance:');
% to do: 237 to end
for Stack=1:size(Table,1) % set back to 1 41b
    Time=Table.Time(Stack);
    cprintf('text',['Stack ',num2str(Stack),' ',Table.Filename{Stack},' Time: ',num2str(Stack)]);
    [NameTable,SibInfo]=fileSiblings_3(Table.Filename{Stack,1});
    FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
    FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
    Res=FileinfoTrace.Res{1};
    MouseId=Table.MouseId(Stack);
    Age=Table.Age(Stack,1);
    
    
    Path2Ratiofile=[NameTable{'OriginalB','Filename'}{1},'_RatioResults.mat'];
    [Path2Ratiofile,Report]=getPathRaw(Path2Ratiofile);
    if Report==0; keyboard; end;
    
    load(Path2Ratiofile);
        Data2add.Volume(Data2add.Distance==50)==0
        
    if isfield(RatioResults,'Histograms')==0 || isfield(RatioResults.Histograms,'DistanceReal2')==0 || RatioResults.Histograms.DistanceReal2.Volume(RatioResults.Histograms.DistanceReal2.Distance==50)==0 % RatioResults.Histograms.DistanceReal2.Volume(50)==0
        if strfind1(FileinfoTrace.ChannelList{1},'Outside',1)
            Table.Outside(Stack,1)=1;
        else
            Table.Outside(Stack,1)=0;
            SourceChannels={'Outside'};
            TargetChannels={'Outside'};
            ratioPlaque_Data2Trace(SourceChannels,TargetChannels,'None',Table.Filename{Stack});
        end
        if strfind1(FileinfoTrace.ChannelList{1},'DistanceReal',1)
            Distance=im2Matlab_3(FilenameTotalTrace,'DistanceReal',Time);
        else
            Distance=0;
        end
        if max(Distance(:))==0
%             keyboard;
            DistInOut=im2Matlab_3(FilenameTotalTrace,'DistInOut',Time);
            Membership=im2Matlab_3(FilenameTotalTrace,'Membership',Time);
            PlaqueMap=uint8(DistInOut<=50).*Membership;
            clear DistInOut; clear Membership;
            Selection=NewBornPlaqueList(NewBornPlaqueList.MouseId==MouseId,:);
            % find plaques that are not present yet
            for Pl=1:size(Selection,1)
                if Age<Selection.PlBirth(Pl,1)
                    PlId=Selection.PlId(Pl);
                    PlaqueMap(PlaqueMap==PlId)=0;
                end
            end
            Distance=distanceMat_4(PlaqueMap,'DistInOut',Res,[],1,1,50,'uint8');
            clear PlaqueMap;
            ex2Imaris_2(Distance,FilenameTotalTrace,'DistanceReal',Time);
        end
        Outside=im2Matlab_3(FilenameTotalTrace,'Outside',Time);
        Distance=Distance(Outside<2);
        clear Outside;
%         [~,~,Ranges,Histogram]=cumSumGenerator(Distance,(0:1:256).');
        [~,~,~,HistogramDistanceReal]=cumSumGenerator(Distance,(0:1:256).');
        clear Distance;
        HistogramDistanceReal=table((0:255).',HistogramDistanceReal,'VariableNames',{'Distance';'Volume'}); % measured in pixel not µm
        
%         VolumeTrace=Histogram*prod(Res(:));
%         RatioResults.Histograms.DistanceReal=VolumeTrace;
        RatioResults.Histograms.DistanceReal2=HistogramDistanceReal;
        save(Path2Ratiofile,'RatioResults');
        
        
%     [~,~,~,HistogramDistanceReal]=cumSumGenerator(DistanceReal,(-1:1:255).');
%     HistogramDistanceReal=table((0:255).',HistogramDistanceReal,'VariableNames',{'Distance';'Volume'});
    
    
        
%     else
%         VolumeTrace=RatioResults.Histograms.DistanceReal;
    end
%     TotalVolume=sum(VolumeTrace(:));
%     Table.TotalVolume(Stack,1)=TotalVolume;
%     Table.VolumeTrace{Stack,1}=VolumeTrace;
    
% % %     Ind=find(MouseInfoTime.MouseId==MouseId & MouseInfoTime.Age==Age);
% % %     MouseInfoTime.VolumeDistribution(Ind,:)=MouseInfoTime.VolumeDistribution(Ind,:)+VolumeTrace.';
% % %     MouseInfoTime.TotalVolume2(Ind,1)=MouseInfoTime.TotalVolume2(Ind,1)+TotalVolume;
    
    cprintf('text','\n');
end
keyboard;


