% integrate BoutonInfo into DistRelation
function [MouseInfo]=finalEvaluationSub1(MouseInfo,SingleStacks)
global W;
%% gather info based on plaques
AbsMinMax=[-50,205];
% Timepoints=size(FileTypes.FA{1,1},1);
a=nan(256,1);
DistTimeTable=array2table(a,'RowNames',num2strArray_2((AbsMinMax(1):AbsMinMax(1,2)).'));
% PlaqueData=table; % in X the plaques, in Y the stuff
% SubRegions: a: {[1;2],[2],[3],[4],[1;2;3;4],[5]};
%             b: {[1;2],[2],[3],[4],[1;2;3;4]};

% for Type=1:size(FileTypes,1)
SingleStacks=SingleStacks(strfind1(SingleStacks.Filename,'Hazal_'),:);
for File=1:size(SingleStacks,1)
    Fileinfo=getFileinfo_2([SingleStacks.Filename{File},'.lsm']);
    
    RatioResults=SingleStacks.Data{File};
    TotalDistRelation=RatioResults.DistRelation;
    PlaqueNumber=size(TotalDistRelation,1);
    if isempty(TotalDistRelation.Properties.RowNames)
        TotalDistRelation.Properties.RowNames=num2strArray_2((1:PlaqueNumber).');
    end
    
    %% integrate Surface/Spot infos into TotalDistRelation
    try
        SurfaceInfo=RatioResults.Statistics;
        keyboard;
        for Surf=fieldnames(SurfaceInfo).'
            Statistics=SurfaceInfo.(Surf{1});
            VariableNames=varName2Col(Statistics.ChannelNames);
            ObjInfo=Statistics.ObjInfo;
            if isstruct(ObjInfo) % discontinued because now standardreadout is table format
                ObjInfo=struct2table(ObjInfo);
            end
            ObjInfo.Membership=ObjInfo.IntensityCenter(:,VariableNames.Membership);
            ObjInfo.Relationship=ObjInfo.IntensityCenter(:,VariableNames.Relationship);
            
            ObjInfo.Distance=ObjInfo.IntensityCenter(:,VariableNames.DistInOut)-50;
            % remove everything with IntensityMin(DistInOut&Membershp) of zero
            ObjInfo(ObjInfo.IntensityMin(:,VariableNames.DistInOut)==0&ObjInfo.IntensityMin(:,VariableNames.Membership)==0,:)=[];
            % remove eveything with Xpos between Border and +0.1µm
            %             keyboard; % check GetExtendMin
            %             Wave1=find( ObjInfo.PositionX<Fileinfo.GetExtendMinX+0.1|ObjInfo.PositionX>Fileinfo.GetExtendMaxX-0.1...
            %                 |ObjInfo.PositionY<Fileinfo.GetExtendMinY+0.1|ObjInfo.PositionY>Fileinfo.GetExtendMaxY-0.1...
            %                 |ObjInfo.PositionZ<Fileinfo.GetExtendMinZ+0.1|ObjInfo.PositionZ>Fileinfo.GetExtendMaxZ-0.1...
            %                 );
            Wave1=find( ObjInfo.PositionX<Fileinfo.UmStart{1}(1)+0.1|ObjInfo.PositionX>Fileinfo.UmEnd{1}(1)-0.1...
                |ObjInfo.PositionY<Fileinfo.UmStart{1}(2)+0.1|ObjInfo.PositionY>Fileinfo.UmEnd{1}(2)-0.1...
                |ObjInfo.PositionZ<Fileinfo.UmStart{1}(3)+0.1|ObjInfo.PositionZ>Fileinfo.UmEnd{1}(3)-0.1...
                );
            ObjInfo(Wave1,:)=[];
            Container=table;
            if strfind1(Surf,{'AutofluoSurface';'AutofluoSurface2'},1) % ;'Dystrophies2Surf'
                if strcmp(Surf,'AutofluoSurface2') % Autofluo of VGLUT-image
                    AutofluoVolumeThreshold=10;
                elseif strcmp(Surf,'AutofluoSurface') % Autofluo of Methoxy image
                    AutofluoVolumeThreshold=60;
                end
                % Number of particles
                Container.Name(1,1)={'AutofluoNumber'};
                Container.ObjInfo(1,1)={ObjInfo};
                
                Container.Name(2,1)={'AutofluoSmall'};
                Container.ObjInfo(2,1)={ObjInfo(ObjInfo.Volume<AutofluoVolumeThreshold,:)};
                
                Container.Name(3,1)={'AutofluoLarge'};
                Container.ObjInfo(3,1)={ObjInfo(ObjInfo.Volume>=AutofluoVolumeThreshold,:)};
                
            elseif strfind1(Surf,{'Boutons1';'Boutons2'},1)
                if strcmp(Surf,'Boutons1')
                    BoutonDiameterXThreshold=1;
                elseif strcmp(Surf,'Boutons2')
                    BoutonDiameterXThreshold=2;
                end
                
                % remove everything with GRratio below 20
                ObjInfo=ObjInfo(ObjInfo.IntensityMean(:,VariableNames.GRratio)>20,:);
                
                Container.Name(1,1)={[Surf{1},'Number']};
                Container.ObjInfo(1,1)={ObjInfo};
                
                Container.Name(2,1)={[Surf{1},'Small']};
                Container.ObjInfo(2,1)={ObjInfo(ObjInfo.DiameterX<=1,:)};
                
                Container.Name(3,1)={[Surf{1},'Large']};
                Container.ObjInfo(3,1)={ObjInfo(ObjInfo.DiameterX>1,:)};
                
            elseif strfind1(Surf,{'Dystrophies2Surf';'Dystrophies1Surf'},1) % ;'Dystrophies2Surf'
                A1=1;
            end
            
            for Con=1:size(Container,1)
                ObjInfo=Container.ObjInfo{Con,1};
                %                 J=struct; J.ExcludeRoiIds={[-50],[0],[0]};
                Out=Summer_3({[]},{ObjInfo.Distance,ObjInfo.Membership,ObjInfo.Relationship},{[-50],[0],[0]});
                SubRegionNumber=size(Out.SumRes,3);
                for Pl=1:size(Out.RoiIds{2,1},1)
                    %                 for Pl=Out.MinMax(2,1):Out.MinMax(2,2)
                    %                 for Pl=Out.RoiIds{2,1}.'
                    %                     for Pl=1:size(Out.SumRes,2)
                    PlId=num2str(Out.RoiIds{2,1}(Pl,1));
                    for Sub=1:SubRegionNumber
                        if isempty(TotalDistRelation.Data{PlId,1}.Properties.RowNames)
                            TotalDistRelation.Data{PlId,1}.Properties.RowNames=num2strArray_2(TotalDistRelation.Data{PlId,1}.Distance); % remove for newer version
                        end
                        Distance=(Out.MinMax(1,1):Out.MinMax(1,2)).';
                        TotalDistRelation.Data{PlId,Sub}{num2strArray_2(Distance),'Distance'}=Distance;
                        Data=Out.SumRes(:,Pl,Sub);
                        TotalDistRelation.Data{PlId,Sub}{num2strArray_2(Distance),Container.Name{Con,1}}=Data;
                        TotalDistRelation.Data{PlId,Sub}=sortrows(TotalDistRelation.Data{PlId,Sub},'Distance');
                    end
                end
            end
        end
    end
    
    
    
end
keyboard;
% end
