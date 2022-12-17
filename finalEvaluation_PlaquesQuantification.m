% quantification of single plaques
function [PlaqueList,PlaqueListSingle]=finalEvaluation_PlaquesQuantification(MouseInfo)
PlaqueList=table;
PlaqueListSingle=table;
tic
Loop=struct('Ind',0,'Selection',[]);
while Loop.Ind>=0
    Loop=struct('Type','MouseInfo','MouseInfo',MouseInfo,'Ind',Loop.Ind,'Selection',Loop.Selection);
    [Loop]=looper(Loop);
    if Loop.Ind<0; break; end
    
    % calculate Radii linear growth
    
    Table=table;
    Table.BorderTouch=Loop.PlaqueData.BorderTouch;
    Table.Age=Loop.Age(1:size(Table,1));
    Table.Values=Loop.PlaqueData.Radius;
    Table.XYZCenter=Loop.PlaqueData.UmCenter;
    
    for m=1:size(Table,1)
       if isequal(Table.XYZCenter{m},[1;1;1]) || isempty(Table.XYZCenter{m})
           Table.Values(m,1)=NaN;
       end
    end
    Table.Out(Table.Values==0|Table.BorderTouch~=0,1)=1;
    [DataOut]=fit2TimeSections(Loop.TimeSections,Table);
       
    % determine if newborn
    Wave1=find(isnan(Table.Values));
    DataOut.PlBirth=NaN;
    if isempty(Wave1)==0 | min(Wave1)==1
        for m=1:size(Table,1)
           if isnan(Table.Values(m))==0
               Appearance=m;
               break;
           end
        end
        if min(Table.BorderTouch(1:Appearance-1))==0
            % find next three not Bordertouching Plaques
            
            Wave2=Table(Table.Age<Table.Age(Appearance)+18&Table.Age>=Table.Age(Appearance)&Table.BorderTouch==0,:);
            Wave2.ApproxRadius=Wave2.Values-(Wave2.Age-Table.Age(Appearance-1))*0.3/7;
            
            if isempty(Wave2)==0 && mean(Wave2.ApproxRadius)<3
                DataOut.PlBirth=Table.Age(Appearance);
                Table.Values(1:Appearance-1,1)=0;
            end
        end
    end
    
    % determine plaque growth before and after treatment
    Table.TreatmentType(:,1)={Loop.TreatmentType};
    Table.Values(Table.BorderTouch~=0)=NaN;
    Table.Values(Table.Values==0)=NaN;
    Wave1=[Table.Age-16,Table.Age+16];
    if strcmp(Loop.TreatmentType,'NB360')
%         keyboard;
        Table.TreatmentType(Table.Age<Loop.StartTreatmentNum,1)={'NB360Vehicle'};
        
        Wave2=Loop.StartTreatmentNum;
        Wave1(Table.Age<Wave2&Wave1(:,2)>Wave2,2)=Wave2;
        Wave1(Table.Age>=Wave2&Wave1(:,1)<Wave2,1)=Wave2;
    end
    
    Wave2=fit2TimeSections(Wave1,Table);
    Table.Growth=Wave2.Growth.';
    Table.Time2Treatment=Table.Age-Loop.StartTreatmentNum;
%     Table.Growth(:,1)=NaN;
    
% % % %     Table.Values(Table.BorderTouch~=0)=NaN;
% % % %     Wave1=Table.Values(2:end)-Table.Values(1:end-1);
% % % %     Wave2=Table.Age(2:end)-Table.Age(1:end-1);
% % % %     Wave1=Wave1./Wave2*7;
% % % %     Wave1=[NaN;Wave1];
% % % %     Table.Growth(:,1)=Wave1;
%     PlaqueData=Loop.PlaqueData;
    PlaqueData=[Loop.PlaqueData,Table(:,{'Age','Growth','TreatmentType','Time2Treatment'})];
    PlaqueData.MouseId(:,1)=Loop.MouseId;
    PlaqueData.Mouse(:,1)=Loop.Mouse;
    PlaqueData.RoiId(:,1)=Loop.RoiId; %     PlaqueData.RoiData(:,1)=Loop.RoiId;
    PlaqueData.Pl(:,1)=Loop.Pl;
    Wave1=cell(size(PlaqueData,1),2); Wave1(:,1:size(Loop.Filenames,2))=Loop.Filenames(1:size(Wave1,1),:);
    PlaqueData.Filenames=Wave1;
    PlaqueData.Time(:,1)=(1:size(PlaqueData,1)).';
    
    PlaqueData=PlaqueData(:,{'MouseId','RoiId','Pl','Time','Radius','BorderTouch','UmCenter','Age','Growth','TreatmentType','Time2Treatment','Mouse','Filenames'});
    
%     PlaqueListSingle(end+1,)=;
    PlaqueListSingle=[PlaqueListSingle;PlaqueData];
    
%     MouseInfo.RoiInfo{Loop.Mouse}.TraceData{Loop.RoiData,1}.Data{Loop.Pl,1}.Growth=Table.Growth;
%     MouseInfo.RoiInfo{Loop.Mouse}.TraceData{Loop.RoiData,1}.Data{Loop.Pl,1}.Age=Table.Age;
    
    PlaqueList(end+1,{'MouseId','RoiId','Pl','PlaqueListSingle','Mouse','TreatmentType','StartTreatmentNum'})={Loop.MouseId,Loop.RoiId,Loop.Pl,{PlaqueData},Loop.Mouse,{Loop.TreatmentType},Loop.StartTreatmentNum};
    PlaqueList(end,{'PlBirth'})=DataOut(1,{'PlBirth'});
%     PlaqueList.Timepoints(end,1:size(DataOut.Timepoints,2))=DataOut.Timepoints;
    PlaqueList.Timepoints(size(PlaqueList,1),1:size(DataOut.Timepoints,2))=DataOut.Timepoints;
    PlaqueList.PlRadPerWeek(size(PlaqueList,1),1:size(DataOut.Growth,2))=DataOut.Growth;
    PlaqueList.PlFitLines(size(PlaqueList,1),1:size(DataOut.FitLines,2))=DataOut.FitLines;
%     MouseInfo.RoiInfo{Loop.Mouse}.TraceData{Loop.RoiData,1}(Loop.Pl,{'Timepoints','PlRadPerWeek','PlFitLines','PlBirth'})=DataOut(1,{'Timepoints','Growth','FitLines','PlBirth'});
    
end

disp(['finalEvaluation_PlaquesQuantification: ',num2str(round(toc/60)),'min']);
