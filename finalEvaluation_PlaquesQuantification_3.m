% quantification of single plaques
function [PlaqueList,PlaqueListSingle]=finalEvaluation_PlaquesQuantification_3(MouseInfo,PlaqueListSingle) %CaseOutliars,LoadData

CaseOutliars=finalEvaluation_CaseOutliars(MouseInfo);
PlaqueList=table;
tic
Loop=struct('Ind',0,'Selection',[]);
while Loop.Ind>=0 % && Loop.Ind<=1030
    Loop=struct('Type','MouseInfo','MouseInfo',MouseInfo,'Ind',Loop.Ind,'Selection',Loop.Selection);
    [Loop]=looper(Loop);
    if Loop.Ind<0; break; end
    % %     if Loop.MouseId==480; else; continue; end;
    %     if Loop.MouseId==480 && Loop.Pl>=7; else; continue; end;
    % calculate Radii linear growth
    if Loop.StartTreatmentNum==0; Loop.StartTreatmentNum=4*30.42; end;
    StartNum=Loop.StartTreatmentNum;
    
    
    PlaqueData=Loop.PlaqueData;
    Wave1=cell(size(PlaqueData,1),2); Wave1(:,1:size(Loop.Filenames,2))=Loop.Filenames(1:size(Wave1,1),:);
    PlaqueData.Filenames=Wave1;
    PlaqueData.Age=Loop.Age(1:size(PlaqueData,1));
    PlaqueData.Time(:,1)=(1:size(PlaqueData,1)).';
    
    try
        InterpolateTp=CaseOutliars{num2str(Loop.MouseId),'InterpolateTp'}{1};
        if isempty(InterpolateTp)==0
            for m=1:size(InterpolateTp,1)
                PlaqueData(end+1,{'Age','Radius','BorderTouch','Out'})={InterpolateTp(m)+StartNum,NaN,1000,1};
            end
        end
    end
    PlaqueData=sortrows(PlaqueData,'Age');
    RemoveTp=CaseOutliars{num2str(Loop.MouseId),'RemoveTp'}{1};
    if isempty(RemoveTp)==0
        PlaqueData(RemoveTp,{'BorderTouch'})={2};
    end
    
    Table=PlaqueData(:,{'Age','Radius','UmCenter','BorderTouch','Filenames','Time'});
    
    Table.Distance2Border=min(PlaqueData.DistanceCenter2TopBottom,[],2);
    
    Table.Time2Treatment=Table.Age-StartNum;
    Table.TreatmentType(:,1)={Loop.TreatmentType};
    if strcmp(Loop.TreatmentType,'NB360')
        Table.TreatmentType(Table.Age<StartNum,1)={'NB360Vehicle'};
    end
    
    for m=1:size(Table,1)
        if isequal(Table.UmCenter{m},[1;1;1]) || isempty(Table.UmCenter{m})
            Table.Radius(m,1)=NaN;
        end
    end
    
    
    % interpolate radius
    % % % %     Table.Out(1)=1;
    Table.RadiusFit1(:,1)=NaN;
    Table.Growth(:,1)=NaN;
    
    % set all plaques touching Border and with distance between 1.5 to 6 back to zero
    Wave1=find(Table.BorderTouch==1 & min(Table.Distance2Border,[],2)>1.5 & min(Table.Distance2Border,[],2)<=6);
    Table.BorderTouch(Wave1)=0;
    
    [Table,Coefs,PlaqueSizeFit,PlBirth]=finalEvaluation_PlaquesQuantification_Fitting_2(Loop,Table,CaseOutliars);
    
    VariableNames={'Age';'RadiusFit1';'Growth';'TreatmentType';'Time2Treatment';'BorderTouch'};
    PlaqueData(1:size(Table,1),VariableNames.')=Table(:,VariableNames.');
    PlaqueData.MouseId(:,1)=Loop.MouseId;
    PlaqueData.Mouse(:,1)=Loop.Mouse;
    PlaqueData.RoiId(:,1)=Loop.RoiId;
    PlaqueData.PlId(:,1)=Loop.Pl;
    
    
    VariableNames={'MouseId','RoiId','PlId','Time','Radius','RadiusFit1','Distances','BorderTouch','UmCenter','Age','Growth','TreatmentType','Time2Treatment','Mouse','Filenames'};
    
    for Pl=1:size(PlaqueData,1)
        try
            Ind=[];
            Ind=find(PlaqueListSingle.MouseId==Loop.MouseId & PlaqueListSingle.RoiId==Loop.RoiId & PlaqueListSingle.PlId==Loop.Pl & PlaqueListSingle.Age==PlaqueData.Age(Pl));
        end
        if isempty(Ind); Ind=size(PlaqueListSingle,1)+1; end;
        PlaqueListSingle(Ind,VariableNames)=PlaqueData(Pl,VariableNames);
    end
    
    Ind2Add=size(PlaqueList,1)+1;
    PlaqueList(Ind2Add,{'MouseId','RoiId','PlId','PlaqueListSingle','Mouse','TreatmentType','StartTreatmentNum'})={Loop.MouseId,Loop.RoiId,Loop.Pl,{PlaqueData},Loop.Mouse,{Loop.TreatmentType},StartNum};
    PlaqueList.PlBirth(Ind2Add)=PlBirth;
    PlaqueList.LoopInd(Ind2Add,1)=Loop.Ind;
    try; PlaqueList.Coefs1(Ind2Add,1:size(Coefs{1},1))=Coefs{1}.'; end;
    try; PlaqueList.Coefs2(Ind2Add,1:size(Coefs{2},1))=Coefs{2}.';end;
    try; PlaqueList.PlaqueSizeFit(Ind2Add,1)={PlaqueSizeFit};end;
    
end
PlaqueListSingle=finalEvaluation_PlaqueClosestDistance_3(PlaqueListSingle);
save(getPathRaw('FinalEvaluation_PlaqueListSingle.mat'),'PlaqueListSingle');
save(getPathRaw('FinalEvaluation_PlaqueList.mat'),'PlaqueList');
disp(['finalEvaluation_PlaquesQuantification: ',num2str(round(toc/60)),'min']);


