function [FitCoef,Rotate]=fitCoefSummer(FitCoefs,Rotates)

for m=1:size(Rotates,1)
    if ischar(Rotates{m})
        Rotates(m,1)={variableExtract(Rotates{m,1},{'X';'Y';'Z'})};
    end
end
FitCoefs=[{zeros(3,3)};FitCoefs];
for m=size(FitCoefs,1):-1:2
    if Rotates{m-1}.Z==180
        FitCoefs{m,1}(1:2,:)=-FitCoefs{m,1}(1:2,:);
    end
    FitCoefs{m-1,1}=FitCoefs{m-1,1}+FitCoefs{m,1};
end

[Rotate]=rotateSummer(Rotates);
FitCoef=FitCoefs{m,1};
