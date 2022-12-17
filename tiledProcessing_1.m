function DataOut=tiledProcessing_1(Data3D,Outside,Res,ResLevels,Calculation,CS) % CS for CalcSettings
timeTable('tiledProcessing_Start');
% if exist('ResLevels','Var')==0
% %     ResLevels=table;
%     ResLevels={  'Res','Tiling','Overlap';...
%         1.5,10^9,10;...
%         5,Inf,0;...
%         };
%     ResLevels=array2table(ResLevels(2:end,:),'VariableNames',ResLevels(1,:));
% end


Pix=size(Data3D).';
Um=Pix.*Res;

for Level=1:size(ResLevels,1)
    Divisions=table;
    Divisions.Div(size(Divisions,1)+1,1)={[1;1;1]};
    for m=1:9999
        Wave1=Um./Divisions.Div{end};
        Divisions.Um(size(Divisions,1),1)={Wave1};
        Divisions.UmWithOverlap(size(Divisions,1),1)={Wave1+2*ResLevels.Overlap{Level}};
        Divisions.PixWithOverlap(size(Divisions,1),1)={Wave1./ResLevels.Res{Level,1}};
        Divisions.PixTotal(size(Divisions,1),1)=prod(Divisions.PixWithOverlap{end,1});
        [~,Wave1]=max(Divisions.UmWithOverlap{end});
        Wave2=Divisions.Div{end,1}; Wave2(Wave1)=Wave2(Wave1)+1;
        if Divisions.PixTotal(end)<ResLevels.Tiling{Level,1}
            break;
        end
        Divisions.Div(size(Divisions,1)+1,1)={Wave2};
    end
    VariableNames=Divisions.Properties.VariableNames.'; % {'Div';'Um';'Pix';'PixTotal'}
    ResLevels(Level,VariableNames)=Divisions(end,VariableNames);
    PixTiles=ResLevels.Div{Level};
%     UmTiles=Um./PixTiles;
    Table=table;
    [Wave1,Wave2,Wave3]=ind2sub(PixTiles.',1:prod(PixTiles));
    Table.XYZ=[Wave1.',Wave2.',Wave3.'];
    for Tile=1:size(Table,1)
%         Tile=60;
        Wave1=Table.XYZ(Tile,:).';
        Start=(Wave1-1).*ResLevels.Um{Level};
        End=Wave1.*ResLevels.Um{Level};
        Table.Um(Tile,1)={[Start,End]};
%         Table.Um(Tile,1:6)=[Start;End];
%         Wave1=floor([Start,End]./ResLevels.Res{Level})+1;
        Wave1=floor([Start,End-0.000001]./Res)+1;
        Table.Pix(Tile,1)={Wave1};
        Start=Start-ResLevels.Overlap{Level}; Start(Start<0)=0;
        End=End+ResLevels.Overlap{Level}; End(End>Um)=Um(End>Um);
        Table.UmWithOverlap(Tile,1)={[Start,End]};
        Wave1=floor([Start,End-0.000001]./Res)+1;
        Table.PixWithOverlap(Tile,1)={Wave1};
        
        
        Wave1=Table.PixWithOverlap{Tile,1};
        Data3DSel=Data3D(Wave1(1,1):Wave1(1,2),Wave1(2,1):Wave1(2,2),Wave1(3,1):Wave1(3,2));
        if exist('Outside','Var')==1
            OutsideSel=Outside(Wave1(1,1):Wave1(1,2),Wave1(2,1):Wave1(2,2),Wave1(3,1):Wave1(3,2));
        end
        if strcmp(Calculation,'distanceMat')
            keyboard;
            if max(Data3DSel(:))==0
                DataOutSel=Data3DSel; DataOutSel(:)=65535;
            else
                [DataOutSel]=distanceMat_4(Data3DSel,{'DistInOut'},Res,1,1,0,0,'uint16',ResLevels.Res{Level});
            end
        elseif strcmp(Calculation,'percentileFilter3D')
            DataOutSel=percentileFilter3D_3(Data3DSel,CS.Percentile,Res,ResLevels.Res{Level},OutsideSel,CS.BackgroundCorrection,CS.Window,CS.ReplaceWithClosest);
        elseif strcmp(Calculation,'watershedSegmentation_2')
            [PlaqueMapWatershed,LocalMaxima,Wave1,Seeds]=watershedSegmentation_2(DataOutSel,CS.Version,Res,CS.WatershedData);
        else
            keyboard;
        end
        
        Wave1=[[1;1;1],size(Data3DSel).']-(Table.PixWithOverlap{Tile,1}-Table.Pix{Tile,1});
        Table.PixExcise(Tile,1)={Wave1};
        
        Wave1=Table.PixExcise{Tile,1};
        DataOutSel=DataOutSel(Wave1(1,1):Wave1(1,2),Wave1(2,1):Wave1(2,2),Wave1(3,1):Wave1(3,2));
        Wave1=Table.Pix{Tile,1};
        DataOut(Wave1(1,1):Wave1(1,2),Wave1(2,1):Wave1(2,2),Wave1(3,1):Wave1(3,2))=DataOutSel;
    end
end
timeTable('tiledProcessing_End');