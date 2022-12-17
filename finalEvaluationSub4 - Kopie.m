function [PlaqueData]=finalEvaluationSub4(PlaqueData,FileTypes)

PlaqueNumber=size(PlaqueData,1);
TypeNumber=2;
SubRegionNumber=6;



for Type=1:TypeNumber
    Res3D=nan(size(FileTypes.FA{Type,1},1),1);
    for Time=1:size(FileTypes.FA{Type,1},1)
        if isempty(FileTypes.FA{Type,1}.RatioResults{Time,1})==0
            Res3D(Time,1)=prod(FileTypes.FA{Type,1}.Fileinfo{Time,1}.Res{1});
        else
            Timepoints=Time-1;
            break
        end
    end
end


for Pl=1:PlaqueNumber
    for Sub=1:SubRegionNumber
        PlaqueData.DistInfo{Pl,Sub}.Properties.RowNames{1}='Original';
        %             A1=emptyRow(PlaqueData.DistInfo{Pl,Sub});
        %             PlaqueData.DistInfo{Pl,Sub}{'Specific',1}={struct};
        % % % %             Wave1=strfind1(PlaqueData.DistInfo{Pl,Sub}.Properties.VariableNames.','Autofluo',1);
        % % % %             if Type~=1 && Wave1~=0
        % % % %                 PlaqueData.Vector{Pl,Type}.Properties.VariableNames{Wave1}='AutofluoSurface2';
        % % % %             end
        % Volume
        AdjustedRes3D=Res3D; % exclude columns that already were divied through Res3D
        Volume=PlaqueData.DistInfo{Pl,Sub}{'Original','Volume'}{1}{:,:};
        Wave2=rem(Volume,1);
        Wave2=nansum(Wave2,1);
        AdjustedRes3D(Wave2(:)~=0)=1;
        Volume=Volume.*repmat(AdjustedRes3D.',[256,1]);
        Vol=Volume;
        NormTotal=Volume/max(Volume(:))*100;
        MaxVector=max(Volume,[],1);
        NormTp=Volume./repmat(MaxVector,[256,1])*100;
        
        Modifications=PlaqueData.Vector{Pl,Type}.Properties.VariableNames.';
        Modifications(strfind1(Modifications,'Volume',1),:)=[];
        Modifications=[{'Volume'};Modifications];
        
        for Mod=Modifications.'
            CalcTypes=cell(0,0);
            Original=PlaqueData.Vector{Pl,Type}{'Original',Mod}{1};
            if strfind1({'Dystrophies'},Mod,1)
                OrigVolume=Volume;
                Vol=nan(256,size(Original,2));
                Volume=nan(256,size(Original,2));
                
                for m3=1:Timepoints
                    if size(Original{:,m3},2)==2
                        Volume(:,m3)=Original{:,m3}(:,1);
                        Vol(:,m3)=Original{:,m3}(:,2);
                    end
                end
                
                VglutGreen=PlaqueData.Vector{Pl,Type}{'Original','VglutGreen'}{1}{:,:};
                VglutGreen=VglutGreen./OrigVolume;
                VglutGreen=VglutGreen-repmat(min(VglutGreen,[],1),[256,1]);
                VglutGreen=VglutGreen./repmat(VglutGreen(50,:),[256,1]);
                Vol(1:50,:)=Vol(1:50,:).*VglutGreen(1:50,:);
                Original=array2table(Vol,'VariableNames',Original.Properties.VariableNames.','RowNames',Original.Properties.RowNames.');
                Volume=Volume.*repmat(Res3D.',[256,1]);
                CalcTypes=[CalcTypes;{'Vol'}];
                
                Wave1=Original;
                Wave1{:,:}=Volume;
                PlaqueData.Vector{Pl,Type}{'Specific',Mod}{1}.Volume=Wave1;
            end
            
            if strfind1({'AutofluoSurface';'AutofluoSurface2';'Blood';'Dystrophies'},Mod,1)
                Vol=Original{:,:}.*repmat(Res3D.',[256,1]);
                Original{:,:}=Vol; % prepare for density calculation
                CalcTypes=[CalcTypes;{'Vol'}];
            end
            if strfind1({'Distance';'Volume'},Mod,1)==0
                Density=Original{:,:}./Volume;
                NormTotal=Density/max(Density(:))*100;
                MaxVector=max(Density,[],1);
                NormTp=Density./repmat(MaxVector,[256,1])*100;
                CalcTypes=[CalcTypes;{'Density';'NormTotal';'NormTp'}];
            end
            
            
            for Calc=CalcTypes.'
                if exist(Calc{1})==1
                    Data=eval(Calc{1});
                    Original{:,:}=Data(:,:);
                    PlaqueData.Vector{Pl,Type}{Calc,Mod}={Original};
                end
            end
            %             clear(CalcTypes{:})
            if strfind1({'Dystrophies'},Mod,1)
                Volume=OrigVolume;
            end
        end
    end
end
