function [ObjInfo]=spotIntensityReader(ObjInfo,Data,Name,Type,Res)

if exist('Type')~=1
    Type='Standard';
end

if strcmp(Type,'Sphere')
    Timer=datenum(now);
    Pix=uint16(size(Data{1}).');
    MaskTable=table;
    for m=1:size(ObjInfo,1)
        if datenum(now)-Timer>1/24/60
            Timer=datenum(now);
            disp(m);
        end
        PixRadius=uint16(round([ObjInfo.RadiusX(m);ObjInfo.RadiusY(m);ObjInfo.RadiusZ(m)]./Res));
        
        try
            Wave1=find(MaskTable.Id==PixRadius(1)*100+PixRadius(2)*10+PixRadius(3));
            Window=MaskTable.Window{Wave1};
        catch
            %         PixRadius=PixRadius*2-1;
            PixRadius(PixRadius==0)=1;
            Max=max(PixRadius(:));
            Number=2*Max-1;
            
            Value=double(repmat(Max,[3,1])./PixRadius*Max);
            
            X=linspace(-Value(1),Value(1),Number).';
            Y=linspace(-Value(2),Value(2),Number);
            Z=zeros(1,1,Number);
            Z(:)=linspace(-Value(3),Value(3),Number);
            
            X=repmat(X,[1,Number,Number]);
            Y=repmat(Y,[Number,1,Number]);
            Z=repmat(Z,[Number,Number,1]);
            
            Window=sqrt(X.^2+Y.^2+Z.^2)<=Max;
            Cut=[repmat(Max,[3,1])-PixRadius+1];
            Cut(:,2)=repmat(Number,[3,1])-Cut(:,1)+1;
            Window=Window(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),Cut(3,1):Cut(3,2));
            
            MaskTable(size(MaskTable,1)+1,{'Id','Window'})={PixRadius(1)*100+PixRadius(2)*10+PixRadius(3),{Window}};
        end
        
        Cut=[double(ObjInfo.PixXYZ(m,:).')+1-double(PixRadius),double(ObjInfo.PixXYZ(m,:).')+double(PixRadius)-1];
        Outside=double(uint16([[1;1;1]-Cut(:,1),Cut(:,2)-double(Pix)]));
        Cut=[Cut(:,1)+Outside(:,1),Cut(:,2)-Outside(:,2)];
        Window=Window(1+Outside(1,1):end-Outside(1,2),1+Outside(2,1):end-Outside(2,2),1+Outside(3,1):end-Outside(3,2));
        for m2=1:size(Data,1)
            Wave1=Data{m2}(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),Cut(3,1):Cut(3,2)).*uint8(Window);
            ObjInfo{m,Name{m2,1}}=mean(Wave1(:));
        end
        
    end
end

if strcmp(Type,'Standard')
    for m=1:size(ObjInfo,1)
        ObjInfo{:,Name{m,1}}=Data{m}(ObjInfo.Ind);
    end
end
