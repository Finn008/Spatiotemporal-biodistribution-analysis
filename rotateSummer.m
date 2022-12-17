function [Rotate]=rotateSummer(Rotates)

Rotate=struct;
for m=1:size(Rotates,1)
    if ischar(Rotates{m})
        Rotates(m,1)={variableExtract(Rotates{m,1},{'X';'Y';'Z'})};
    end
end
for m=2:size(Rotates,1)
    Rotate.X=Rotates{m-1}.X+Rotates{m}.X;
    Rotate.Y=Rotates{m-1}.Y+Rotates{m}.Y;
    Rotate.Z=Rotates{m-1}.Z+Rotates{m}.Z;
end

if Rotate.X==360; Rotate.X=0; end;
if Rotate.Y==360; Rotate.Y=0; end;
if Rotate.Z==360; Rotate.Z=0; end;

