function [frameLeft, frameRight]= getPigFootFrames(index, mkrPos,...
                                        frameLeftOffset, frameRightOffset,...
                                        markerNames)


frameRight = struct('r',zeros(3,1),'E',zeros(3,3));
frameLeft  = struct('r',zeros(3,1),'E',zeros(3,3));

ey = mkrPos.('RTOE')(index,:)-mkrPos.('RHEE')(index,:);
ey = ey./norm(ey);

rHA = mkrPos.('RANK')(index,:)-mkrPos.('RHEE')(index,:);
eHA = rHA./norm(rHA);

ex = eHA-(eHA*ey').*ey;
ex = ex./norm(ex);

ez = cross(ex,ey);

frameRight.r = (mkrPos.('RHEE')(index,:) + (rHA*ey').*ey)';

if( ~(ex*ey' < 1e-6) )
  here=1;
end

assert(ex*ey' < 1e-6);
assert(ex*ez' < 1e-6);

assert( abs(ex*ex'-1) < 1e-6);
assert( abs(ey*ey'-1) < 1e-6);
assert( abs(ez*ez'-1) < 1e-6);

%Offset
frameRight.E = [ex', ey', ez']*frameRightOffset.E;

frameRight.r = frameRight.r + frameRight.E*frameRightOffset.r;


ey = mkrPos.('LTOE')(index,:)-mkrPos.('LHEE')(index,:);
ey = ey./norm(ey);

rHA = mkrPos.('LANK')(index,:)-mkrPos.('LHEE')(index,:);
eHA = rHA./norm(rHA);

ex = -(eHA-(eHA*ey').*ey);
ex = ex./norm(ex);

ez = cross(ex,ey);

frameLeft.r = (mkrPos.('LHEE')(index,:) + (rHA*ey').*ey)';

assert(ex*ey' < 1e-6);
assert(ex*ez' < 1e-6);

assert( abs(ex*ex'-1) < 1e-6);
assert( abs(ey*ey'-1) < 1e-6);
assert( abs(ez*ez'-1) < 1e-6);

frameLeft.E = [ex', ey', ez']*frameLeftOffset.E;
frameLeft.r = frameLeft.r + frameLeft.E*frameLeftOffset.r;





