function [Results]=finalEvaluation_RecalculateDistance(MouseInfo,PlaqueListSingle,NewBornPlaqueList)

Table=table;
for Mouse=1:size(MouseInfo,1)
    RoiInfo=MouseInfo.RoiInfo{Mouse,1};
    for Roi=1:size(RoiInfo,1)
        if floor(RoiInfo.Roi(Roi))==RoiInfo.Roi(Roi)
            %             Ind=size(Table,1)+1;
            %             Table.MouseId(Ind,1)=MouseInfo.Mouse(Mouse);
            %             Table.Mouse(Ind,1)=Mouse;
            %             Table.Roi(Ind,1)=RoiInfo.Roi(Roi);
            %             Table.StackB(Ind,1)=RoiInfo.StackB(Roi);
            %             Table.Filename(Ind,1)={RoiInfo.Files{Roi,1}.Filenames(1,1)};
            %             Age=RoiInfo.Files{Roi,1}.Age(:,1);
            %             Table.Age(Ind,1:size(Age,1))=Age.';
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
for Stack=1:size(Table,1)
    
        
    Time=Table.Time(Stack);
    cprintf('text',['Stack ',num2str(Stack),' ',Table.Filename{Stack},' Time: ',num2str(Stack)]);
    [NameTable,SibInfo]=fileSiblings_3(Table.Filename{Stack,1});
    FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
    FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
    Res=FileinfoTrace.Res{1};
    MouseId=Table.MouseId(Stack);
    
    Age=Table.Age(Stack,1);
    
    if strfind1(FileinfoTrace.ChannelList{1},'Outside',1)
        Table.Outside(Stack,1)=1;
    else
        Table.Outside(Stack,1)=0;
        SourceChannels={'Outside'};
        TargetChannels={'Outside'};
        ratioPlaque_Data2Trace(SourceChannels,TargetChannels,'None',Table.Filename{Stack});
    end
%     continue;
%     cprintf('text',[num2str(Time),',']);
    
    
    %         if max(Selection.RoiId)>1 % 279
    %             keyboard; % second Roi
    % %         else
    % %             continue;
    %         end
    
    DistInOut=im2Matlab_3(FilenameTotalTrace,'DistInOut',Time);
    Membership=im2Matlab_3(FilenameTotalTrace,'Membership',Time);
    PlaqueMap=uint8(DistInOut<=50).*Membership;
    clear DistInOut; clear Membership;
    
    Selection=NewBornPlaqueList(NewBornPlaqueList.MouseId==MouseId,:);
    % find plaques that are not present yet
    for Pl=1:size(Selection,1)
        if Age<Selection.PlBirth(Pl,1)
            PlId=Selection.Pl(Pl);
            PlaqueMap(PlaqueMap==PlId)=0;
%             disp('Replace');
        end
    end
    
    Distance=distanceMat_4(PlaqueMap,'DistInOut',Res,[],1,1,50,'uint8');
    clear PlaqueMap;
    
    
    
    ex2Imaris_2(Distance,FilenameTotalTrace,'DistanceReal',Time);
    
    Outside=im2Matlab_3(FilenameTotalTrace,'Outside',Time);
    Distance=Distance(Outside<2);
    
    [~,~,~,Histogram]=cumSumGenerator(Distance,(0:1:255).');
    clear Distance;
    VolumeTrace=Histogram*prod(Res(:));
    TotalVolume=sum(VolumeTrace(:));
    Table.TotalVolume(Stack,1)=TotalVolume;
    Table.VolumeTrace{Stack,1}=VolumeTrace;
    
    
    
    
    %     end
    cprintf('text','\n');
end
keyboard;
%         Path2file=regexprep(FilenameTotalTrace,'_Trace.ims','_RatioResults.mat');
%         [Path2file,Report]=getPathRaw(Path2file);
%         load(Path2file,'TotalResults');
%         save(Path2file,'TotalResults');


