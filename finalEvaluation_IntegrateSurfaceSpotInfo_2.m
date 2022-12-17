function [SingleStacks]=finalEvaluation_IntegrateSurfaceSpotInfo_2(SingleStacks,DataAssignment)
tic;
global W; 
% global WQ;

% PlaqueData=table; % in X the plaques, in Y the stuff
% SubRegions: a: {[1;2],[2],[3],[4],[1;2;3;4],[5]};
%             b: {[1;2],[2],[3],[4],[1;2;3;4]};

Wave1=cellfun(@datenum,SingleStacks.Date,repmat({'yyyy.mm.dd HH:MM'},[size(SingleStacks,1),1]));
Wave1=Wave1>datenum('2015.12.04 12:00','yyyy.mm.dd HH:MM');
SingleStacks=SingleStacks(Wave1,:);
for File=1:size(SingleStacks,1)
%     File=753;
    Fileinfo=getFileinfo_2([SingleStacks.Filename{File},'_Ratio']);
    DistRelation=SingleStacks.DistRelation{File};
    PlaqueNumber=size(DistRelation,1);
    if isempty(DistRelation.Properties.RowNames)
        DistRelation.Properties.RowNames=num2strArray_2((1:PlaqueNumber).');
    end
    
    SurfaceInfo=SingleStacks.Statistics{File};
    if isempty(SurfaceInfo); continue; end;
    for Surf=fieldnames(SurfaceInfo).'
        if strcmp(Surf,'Boutons1')~=1
            keyboard;
        end
        Statistics=SurfaceInfo.(Surf{1});
        ObjInfo=Statistics.ObjInfo;
        if isstruct(ObjInfo) % discontinued because now standardreadout is table format
            ObjInfo=struct2table(ObjInfo);
        end
        
        % if not present produce DistInOut,Membership and Relationship
        if strfind1(Statistics.ObjInfo.Properties.VariableNames.','DistInOut')==0
            VariableNames=varName2Col(Statistics.ChannelNames);
            ObjInfo.Membership=ObjInfo.IntensityCenter(:,VariableNames.Membership);
            ObjInfo.Relationship=ObjInfo.IntensityCenter(:,VariableNames.Relationship);
            ObjInfo.DistInOut=ObjInfo.IntensityCenter(:,VariableNames.DistInOut)-50;
            % remove everything with IntensityMin(DistInOut&Membershp) of zero
            ObjInfo(ObjInfo.IntensityMin(:,VariableNames.DistInOut)==0&ObjInfo.IntensityMin(:,VariableNames.Membership)==0,:)=[];
        end
        ObjInfo.Distance=single(ObjInfo.DistInOut)-50;
        
        % remove eveything with Xpos between Border and +0.1µm
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
            
        elseif strfind1(Surf,{'Boutons1'},1)
            BoutonDensity=size(ObjInfo,1)/prod(Fileinfo.Um{1});
            SingleStacks.Statistics{File,1}.Boutons1.BoutonDensity=BoutonDensity;
            
            Container.Name(1,1)={[Surf{1}]}; %             Container.Name(1,1)={[Surf{1},'Number']};
            Container.ObjInfo(1,1)={ObjInfo};
            Container.Type(1,1)={'Normal'};
            
            if strfind1(Fileinfo.FilenameTotal,'Sophie')
                Wave1=[(0:0.01:1).';1000];
                for m=1:size(ObjInfo,1)
                    ObjInfo.Histogram(m,1)=find(Wave1>=ObjInfo.RadiusX(m),1);
                end
                Container.Name(2,1)={[Surf{1},'Histogram']};
                Container.ObjInfo(2,1)={ObjInfo};
                Container.Type(2,1)={'Histogram'};
                Container.HistoData(2,1)={Wave1};
            end
        elseif strfind1(Surf,{'Dystrophies2Surf';'Dystrophies1Surf'},1) % ;'Dystrophies2Surf'
            A1=1;
        end
        
        for Con=1:size(Container,1)
            ObjInfo=Container.ObjInfo{Con,1};
            if strcmp(Container.Type{Con,1},'Histogram')
                Out=Summer_3({[]},{ObjInfo.Distance,ObjInfo.Histogram,ObjInfo.Relationship},{[-50],[],[0]});
                
                for SubId=DataAssignment.SubPools{'Boutons1'}.'
                    Sub=find(Out.RoiIds{3,1}==SubId);
                    if isempty(Sub); continue; end;
                    Data=[Container.HistoData{Con,1}(Out.RoiIds{2,1}),Out.SumRes(1,:,Sub).'];
                    DistRelation.Data{PlId,SubId}{num2strArray_2(Distance),Container.Name{Con,1}}={Data};
                end
                continue;
            end
            Out=Summer_3({[]},{ObjInfo.Distance,ObjInfo.Membership,ObjInfo.Relationship},{[-50],[0],[0]});
            
            Distance=(Out.MinMax(1,1):Out.MinMax(1,2)).';
            DistanceString=num2strArray_2(Distance);
            for Pl=1:size(Out.RoiIds{2,1},1)
                PlId=num2str(Out.RoiIds{2,1}(Pl,1));
%                 A1=DataAssignment.SubRegions('Boutons1');
%                 A1=DataAssignment.SubRegions{'Boutons1'};
%                 for SubId=DataAssignment.SubPools{'Boutons1'}.'
%                     for SubId=WQ.SubRegions.'
                  for SubId=1:6
                    Sub=find(Out.RoiIds{3,1}==SubId);
                    if isempty(Sub); continue; end;
                    if isempty(DistRelation.Data{PlId,1}.Properties.RowNames)
                        DistRelation.Data{PlId,1}.Properties.RowNames=num2strArray_2(DistRelation.Data{PlId,1}.Distance); % remove for newer version
                    end
                    DistRelation.Data{PlId,SubId}{DistanceString,'Distance'}=Distance; % consumes most of time
                    Data=Out.SumRes(:,Pl,Sub);
                    DistRelation.Data{PlId,SubId}{DistanceString,Container.Name{Con,1}}=Data; % consumes most of time
                    DistRelation.Data{PlId,SubId}=sortrows(DistRelation.Data{PlId,SubId},'Distance');
                end
            end
            
        end
    end
    SingleStacks.DistRelation{File}=DistRelation;
end

disp(['finalEvaluation_IntegrateSurfaceSpotInfo: ',num2str(round(toc/60)),'min']);