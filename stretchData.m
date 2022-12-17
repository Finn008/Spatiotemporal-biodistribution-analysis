function Data=stretchData(Data,Boundary)

Data=Data-min(Data(:));

Max=max(Data(:));

Data=Data/Max*(Boundary(2)-Boundary(1));
Data=Data+Boundary(1);

