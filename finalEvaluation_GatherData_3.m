% for every single plaque list different data types
function [PlaqueListSingle]=finalEvaluation_GatherData_3(MouseInfo,SingleStacks,PlaqueListSingle,DataAssignment)
global W;
tic;

for Mod=DataAssignment.Name.'
    PlaqueListSingle(:,Mod)={nan(1,256)};
end

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
                DataAssignmentSel=DataAssignment(DataAssignment.FileType==FileType,:);
                Res3D=SingleStacks.Res3D(File);
                % go through each 'Modification'/'Sub' pair in DataAssignment
                for ModN=1:size(DataAssignmentSel,1)
                    Mod=DataAssignmentSel.Name{ModN};
                    for SubPool=1:size(DataAssignmentSel.SubPools{Mod},1) %size(DistRelation,2)
                        if SubPool>1; keyboard; end; % store different data for this Mod under a different VariableNames
                        Subs2Pool=DataAssignmentSel.SubPools{Mod}{SubPool};
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
                                    if strfind1(Mod,'Volume')==0
                                        Wave1=DistRelation.Data{Pl,Sub}{:,Mod};
                                        Data=[Data,Wave1];
                                    else
                                        Data=NaN;
                                    end
                                end
                            end
                            if isempty(Data); continue; end;
                            Volume=sum(Volume,2);
%                             A1=1;
                            Ind=find(PlaqueListSingle.MouseId==MouseId&PlaqueListSingle.RoiId==RoiId&PlaqueListSingle.Pl==PlId&PlaqueListSingle.Time==Time);
                            ExistingData=PlaqueListSingle{Ind,Mod};
                            Data2=nan(256,1);
                            if strfind1(Mod,'Volume')
                                Data2(Distance+50,1)=Volume.*Res3D;
                                Data2=nansum_3([ExistingData;Data2.'],1);
                            elseif strfind1(Mod,'Boutons1') % as concentration
                                if isempty(Data) % probably old RatioResults version
                                    continue;
                                end
                                Data2(Distance+50,1)=sum(Data,2)./(Volume*Res3D);
                                Data2=nanmean([ExistingData;Data2.'],1);
                            else % as percentage
                                Data2(Distance+50,1)=sum(Data,2)./Volume;
                                Data2=nanmean([ExistingData;Data2.'],1);
                            end
                            PlaqueListSingle{Ind,Mod}=Data2;
                        end
                    end
                end
            end
        end
    end
    disp(Mouse);
end
disp(['finalEvaluation_GatherData: ',num2str(round(toc/60)),'min']);