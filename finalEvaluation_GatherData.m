function [TimeDistTable]=finalEvaluation_GatherData(MouseInfo,SingleStacks)
tic;
AbsMinMax=[-50,205];
a=nan(256,30);
DistTimeTable=array2table(a,'RowNames',num2strArray_2((AbsMinMax(1):AbsMinMax(1,2)).'));
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
                DistRelation=SingleStacks.DistRelation{File}.Density;
                for Sub=[1,2,3] %size(DistRelation,2)
                    for Pl=1:size(DistRelation,1)
                        PlId=SingleStacks.DistRelation{File}.RoiId(Pl);
                        if FileType==1
                            Modifications={'Volume';'MetBlue';'MetRed';'BRratio';'Plaque';'Dystrophies1';'Autofluo1'};
                        else
                            Modifications={'Volume';'VglutGreen';'VglutRed';'GRratio';'Dystrophies2';'Autofluo2';'Boutons1Number';'Boutons1Histogram'};
                        end
                        for Mod=Modifications.'
                            try
                                Data=DistRelation{Pl,Sub}{:,Mod};
                            catch
                                continue;
                            end
                            
                            if strcmp(Mod,'Volume')
                                Mod={['Volume',num2str(FileType)]};
                            end
                            [Ind]=findTDTind(TimeDistTable,MouseId,RoiId,Sub,Mod,PlId,'Raw');
                            if Ind==size(TimeDistTable,1)+1
                                TimeDistTable(Ind,{'MouseId';'RoiId';'Sub';'Mod';'PlId';'Calc';'Data'})={MouseId,RoiId,Sub,Mod,PlId,{'Raw'},{DistTimeTable}};
                            end
                            if strcmp(Mod,'Boutons1Histogram')
                                TimeDistTable.Data{Ind,1}=Data;
                            else 
                                TimeDistTable.Data{Ind,1}{:,Time}=nansum_2([TimeDistTable.Data{Ind,1}{:,Time},Data]);
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