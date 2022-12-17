% for every single plaque list different data types
function [TimeDistTable]=finalEvaluation_GatherData_2(MouseInfo,SingleStacks)
global W;
tic;
TimeDistTable=table;
for Mouse=1:size(MouseInfo,1) % 5,12
    MouseId=MouseInfo.MouseId(Mouse);
    for Roi=1:size(MouseInfo.RoiInfo{Mouse},1)
        RoiId=MouseInfo.RoiInfo{Mouse}.Roi(Roi);
        Files=MouseInfo.RoiInfo{Mouse}.Files{Roi};
        if RoiId-floor(RoiId)>0 % twice the same roi
            Files.Filenames(:,1)={[]};
        end
        
        for Time=1:size(Files,1)
            for FileType=1:size(Files.Filenames,2)
                File=0;
                try; File=strfind1(SingleStacks.Filename,Files.Filenames{Time,FileType}); end;
                if File==0
                    continue;
                end
                DataAssignment=W.DataAssignment(W.DataAssignment.FileType==FileType,:);
                Res3D=SingleStacks.Res3D(File);
                % go through each 'Modification'/'Sub' pair in DataAssignment
                for ModN=1:size(DataAssignment,1)
                    Mod=DataAssignment.Name{ModN};
                    for SubPool=1:size(DataAssignment.SubPools{Mod},1) %size(DistRelation,2)
                        Subs2Pool=DataAssignment.SubPools{Mod}{SubPool};
                        DistRelation=SingleStacks.DistRelation{File};
                        for Pl=1:size(DistRelation,1)
                            
                                PlId=DistRelation.RoiId(Pl);
                                Distance=DistRelation.Data{Pl,1}.Distance;
                                Data=[];
                                Volume=[];
                                for Sub=Subs2Pool.'
                                    try
                                        Wave1=DistRelation.Data{Pl,Sub}.Volume;
                                        Volume=[Volume,Wave1];
                                        if strfind1(Mod,'Volume')
                                        else
                                            Wave1=DistRelation.Data{Pl,Sub}{:,Mod};
                                            Data=[Data,Wave1];
                                        end
                                    end
                                end
                                Volume=sum(Volume,2);
                                if strfind1(Mod,'Volume')
                                    Data=Volume.*Res3D;
                                elseif strfind1(Mod,'Boutons1')
                                    if isempty(Data) % probably old RatioResults version
                                        continue;
                                    end
                                    Data=sum(Data,2)./(Volume*Res3D);
                                else
                                    Data=sum(Data,2)./Volume;
                                end
                                Wave1=nan(256,1);
                                Wave1(Distance(1)+50+1:Distance(1)+50+size(Distance,1))=Data;
                                Data=Wave1;
                                
                                [Ind]=findTDTind(TimeDistTable,MouseId,RoiId,SubPool,Mod,PlId,'Raw');
                                if Ind==size(TimeDistTable,1)+1
                                    TimeDistTable(Ind,{'MouseId';'RoiId';'Sub';'Mod';'PlId';'Calc';'Data'})={MouseId,RoiId,SubPool,{Mod},PlId,{'Raw'},{nan(256,30)}};
                                end
                                if strcmp(Mod,'Boutons1Histogram')
                                    TimeDistTable.Data{Ind,1}=Data;
                                else
                                    TimeDistTable.Data{Ind,1}(:,Time)=nansum_2([TimeDistTable.Data{Ind,1}(:,Time),Data]);
                                end
                            
                        end
                    end
                end
                
            end
        end
    end
    disp(Mouse);
end
disp(['finalEvaluation_GatherData: ',num2str(round(toc/60)),'min']);