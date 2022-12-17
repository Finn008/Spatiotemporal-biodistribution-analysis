function [MatrixValue]=matrixID2Value(MatrixID,Values)
Wave1=uint16(Values);
Wave1=Wave1(MatrixID(MatrixID>0));
MatrixValue=MatrixID;
MatrixValue(MatrixID>0)=Wave1;