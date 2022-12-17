function [Table,MouseInfo]=synaptosomes_FinalEvaluation_PoolData(BoutonData)

MouseInfo=table;
MouseInfo.MouseId=unique(BoutonData.MouseId);
MouseIDstr=strcat('M',num2strArray_3(MouseInfo.MouseId));

Table=table;
for Mouse=1:size(MouseInfo,1)
    MouseID=MouseInfo.MouseId(Mouse);
    MouseIdStr=MouseIDstr{Mouse};
    MouseInfo.TreatmentType(Mouse,1)={BoutonData.TreatmentType{find(BoutonData.MouseId==MouseID,1)}};
    
    Table{'TreatmentType',{'Immuno','Specification','MathOp','Min','Max',MouseIdStr}}={[],'TreatmentType',[],[],[],MouseInfo.TreatmentType{Mouse,1}};
    BoutonData2=BoutonData(find(BoutonData.MouseId==MouseID),:);
    
    Ihcs=unique(BoutonData2.Ihc);
    for Ihc=1:size(Ihcs,1)
        
        %         if Ihc==0
        %             IhcId='';
        %             Readouts={'PreRadiusAll'};
        %         else
        IhcID=Ihcs{Ihc};
        BoutonData3=BoutonData2(strfind1(BoutonData2.Ihc,IhcID,1),:);
        Table{[IhcID,'BoutonNumber'],{'Immuno','Specification','MathOp','Min','Max',MouseIdStr}}={IhcID,'BoutonNumber',[],[],[],size(BoutonData3,1)};
        
        Readouts={'PreRadiusAll';'PreVglutMeanAll';'PreVglutSumAll';'PreVglutRedMeanAll';'PreImmunoMeanAll';'PreImmunoSumAll'};
        Readouts=[Readouts;regexprep(Readouts,'Pre','Post')];
        Readouts=[Readouts;regexprep(Readouts,'All','Hwi')];
        
        Readouts=[Readouts;...
            'Ratio_PostImmunoSumAll_PreVlgutSumAll';...
            'Ratio_PostImmunoSumHwi_PreVlgutSumHwi';...
            'Ratio_PreImmunoSumAll_PreVlgutSumAll';...
            'Ratio_PreImmunoSumHwi_PreVlgutSumHwi';...
            'Ratio_PostImmunoMeanAll_PreVlgutMeanAll';...
            'Ratio_PostImmunoMeanHwi_PreVlgutMeanHwi';...
            'Ratio_PreImmunoMeanAll_PreVlgutMeanAll';...
            'Ratio_PreImmunoMeanHwi_PreVlgutMeanHwi'];
        
        Readouts=array2table(Readouts,'VariableNames',{'Name'});
        
        for Readout=1:size(Readouts,1);
            ReadoutID=Readouts.Name{Readout};
            Readouts.Min(Readout)=min(BoutonData{:,ReadoutID});
            Readouts.Max(Readout)=max(BoutonData{:,ReadoutID});
            Readouts.Prctile(Readout)=prctile(BoutonData{:,ReadoutID},99);
        end
        Readouts.StepNumber(:,1)=101;
        
        
        for Readout=1:size(Readouts,1)
            % single readouts
            ReadoutID=Readouts.Name{Readout};
            MathOp='Mean'; RowInd=[IhcID,'_',ReadoutID,'_',MathOp];
            Table{RowInd,{'Immuno','Specification','MathOp',MouseIdStr}}={IhcID,ReadoutID,MathOp,mean(BoutonData3{:,ReadoutID})};
            
            MathOp='Median'; RowInd=[IhcID,'_',ReadoutID,'_',MathOp];
            Table{RowInd,{'Immuno','Specification','MathOp',MouseIdStr}}={IhcID,ReadoutID,MathOp,median(BoutonData3{:,ReadoutID})};
            
            % distributions
            Edges=linspace(Readouts.Min(Readout),Readouts.Prctile(Readout),Readouts.StepNumber(Readout)).';
            [CumSum,NormHistogram,Ranges,Histogram]=cumSumGenerator(BoutonData3{:,ReadoutID},Edges);
            
            MathOp='Histogram'; RowInd=strcat(IhcID,'_',ReadoutID,'_',MathOp,num2strArray_3((1:size(Ranges,1)).'));
            Table{RowInd,{'Immuno','Specification','MathOp','Min','Max',MouseIdStr}}=[repmat({IhcID},[size(Ranges,1),1]),repmat({ReadoutID},[size(Ranges,1),1]),repmat({MathOp},[size(Ranges,1),1]),num2cell(Ranges(:,1)),num2cell(Ranges(:,2)),num2cell(NormHistogram)];
            
            MathOp='CumSum'; RowInd=strcat(IhcID,'_',ReadoutID,'_',MathOp,num2strArray_3((1:size(Ranges,1)).'));
            Table{RowInd,{'Immuno','Specification','MathOp','Min','Max',MouseIdStr}}=[repmat({IhcID},[size(Ranges,1),1]),repmat({ReadoutID},[size(Ranges,1),1]),repmat({MathOp},[size(Ranges,1),1]),num2cell(Ranges(:,1)),num2cell(Ranges(:,2)),num2cell(CumSum)];
        end
    end
end