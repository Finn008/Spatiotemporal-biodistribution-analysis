function DataOut=tiledProcessing_2(Data3D,Outside,Res,TilingSettings,Calculation,CS) % CS for CalcSettings
timeTable('tiledProcessing_Start');

Pix=size(Data3D).';
Um=Pix.*Res;

for Level=1:size(TilingSettings,1)
    Divisions=table;
    Divisions.Div(size(Divisions,1)+1,1)={[1;1;1]};
    for m=1:9999
        Wave1=Um./Divisions.Div{end};
        Divisions.Um(size(Divisions,1),1)={Wave1};
        Divisions.UmWithOverlap(size(Divisions,1),1)={Wave1+2*TilingSettings.Overlap{Level}};
        Divisions.PixWithOverlap(size(Divisions,1),1)={Wave1./TilingSettings.Res{Level,1}};
        Divisions.PixTotal(size(Divisions,1),1)=prod(Divisions.PixWithOverlap{end,1});
        [~,Wave1]=max(Divisions.UmWithOverlap{end});
        Wave2=Divisions.Div{end,1}; Wave2(Wave1)=Wave2(Wave1)+1;
        if Divisions.PixTotal(end)<TilingSettings.VoxelNumber{Level,1}
            break;
        end
        Divisions.Div(size(Divisions,1)+1,1)={Wave2};
    end
    VariableNames=Divisions.Properties.VariableNames.'; % {'Div';'Um';'Pix';'PixTotal'}
    TilingSettings(Level,VariableNames)=Divisions(end,VariableNames);
    PixTiles=TilingSettings.Div{Level};
%     UmTiles=Um./PixTiles;
    Table=table;
    [Wave1,Wave2,Wave3]=ind2sub(PixTiles.',1:prod(PixTiles));
    Table.XYZ=[Wave1.',Wave2.',Wave3.'];
    for Tile=1:size(Table,1)
%         Tile=60;
        Wave1=Table.XYZ(Tile,:).';
        Start=(Wave1-1).*TilingSettings.Um{Level};
        End=Wave1.*TilingSettings.Um{Level};
        Table.Um(Tile,1)={[Start,End]};
%         Table.Um(Tile,1:6)=[Start;End];
%         Wave1=floor([Start,End]./ResLevels.Res{Level})+1;
        Wave1=floor([Start,End-0.000001]./Res)+1;
        Table.Pix(Tile,1)={Wave1};
        Start=Start-TilingSettings.Overlap{Level}; Start(Start<0)=0;
        End=End+TilingSettings.Overlap{Level}; End(End>Um)=Um(End>Um);
        Table.UmWithOverlap(Tile,1)={[Start,End]};
        Wave1=floor([Start,End-0.000001]./Res)+1;
        Table.PixWithOverlap(Tile,1)={Wave1};
        
        
        Wave1=Table.PixWithOverlap{Tile,1};
        Data3DSel=Data3D(Wave1(1,1):Wave1(1,2),Wave1(2,1):Wave1(2,2),Wave1(3,1):Wave1(3,2));
        if exist('Outside','Var')==1 && isempty(Outside)==0
            OutsideSel=Outside(Wave1(1,1):Wave1(1,2),Wave1(2,1):Wave1(2,2),Wave1(3,1):Wave1(3,2));
        end
        if strcmp(Calculation,'distanceMat_4')
%             keyboard;
            if max(Data3DSel(:))==0
                DataOutSel=Data3DSel; DataOutSel(:)=65535;
                Output{1}=DataOutSel;
            else
                [Output{1}]=distanceMat_4(Data3DSel,CS.Output,Res,CS.UmBin,CS.OutCalc,CS.InCalc,CS.ZeroBin,CS.DistanceBitType,TilingSettings.Res{Level},CS.Dimensionality);
            end
        elseif strcmp(Calculation,'percentileFilter3D_3')
            [Output{1},Output{2}]=percentileFilter3D_3(Data3DSel,CS.Percentile,Res,TilingSettings.Res{Level},OutsideSel,CS.BackgroundCorrection,CS.Window,CS.ReplaceWithClosest);
        elseif strcmp(Calculation,'percentileFilter3D_4')
            [Output{1},Output{2}]=percentileFilter3D_4(Data3DSel,CS.Percentile,Res,TilingSettings.Res{Level},OutsideSel,CS.BackgroundCorrection,CS.Window,CS.ReplaceWithClosest,[],CS.RequestedOutput);
        elseif strcmp(Calculation,'watershedSegmentation_2')
%             keyboard;
            [Output{1},Output{2},Output{3},Output{4}]=watershedSegmentation_2(Data3DSel,CS.Version,Res,CS.WatershedData);
            % put all IDs that do not touch virtual borders
            BorderStack=ones(size(Data3DSel),'uint8');
            Wave1=Table.PixWithOverlap{Tile,1};
            Wave1(Wave1==1)=0;
            Wave2=Wave1(:,2);Wave2(Wave2==Pix)=Wave2(Wave2==Pix)+1;
            Wave1(:,2)=Wave2;
            BorderStack(Wave1(1,1):Wave1(1,2),Wave1(2,1):Wave1(2,2),Wave1(3,1):Wave1(3,2))=0;
            
            BW=bwconncomp(Output{1},6);
            Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); Table.Volume=Table.NumPix*prod(Res(1:3));
            Wave1=accumarray_9(Output{1},BorderStack,@max);
            Table.BorderTouch=Wave1(2:end);
            Table(Table.BorderTouch==1,:)=[];
            keyboard; % put all remaining structures regardless of overhang into final 3D stack
        else
            keyboard;
        end
        
        Wave1=[[1;1;1],size(Data3DSel).']-(Table.PixWithOverlap{Tile,1}-Table.Pix{Tile,1});
        Table.PixExcise(Tile,1)={Wave1};
        for m=1:size(Output,2)
            if isempty(Output{m})
                continue;
            end
%             if exist(['Output',num2str(m)],'Var')==0;break;end;
            Wave1=Table.PixExcise{Tile,1};
            Wave2=Output{m}(Wave1(1,1):Wave1(1,2),Wave1(2,1):Wave1(2,2),Wave1(3,1):Wave1(3,2));
            Wave1=Table.Pix{Tile,1};
            DataOut{m}(Wave1(1,1):Wave1(1,2),Wave1(2,1):Wave1(2,2),Wave1(3,1):Wave1(3,2))=Wave2;
        end
    end
end
timeTable('tiledProcessing_End');