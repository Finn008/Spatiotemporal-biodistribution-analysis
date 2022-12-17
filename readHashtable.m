function [Out]=readHashtable(Hashtable)

Out=table;
HashtableKeys = Hashtable.keySet().iterator();
for m=1:Hashtable.size()
  Key=HashtableKeys.nextElement();
  Value=Hashtable.get(Key);
  if ischar(Value) && isempty(str2num(Value))==0
      Value=str2num(Value);
  end
  Out.Tag(m,1)={Key};
  Out.Value(m,1)={Value};
end
A1=1;