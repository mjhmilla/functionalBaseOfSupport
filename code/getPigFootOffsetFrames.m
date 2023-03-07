function [frameLeftOffset, frameRightOffset]=...
        getPigFootOffsetFrames(index, mkrPos)


frameRightOffset = struct('r',zeros(3,1),'E',zeros(3,3));
frameLeftOffset  = struct('r',zeros(3,1),'E',zeros(3,3));

%Right frame
ey = mkrPos.('RTOE')(index,:)-mkrPos.('RHEE')(index,:);
ey = ey./norm(ey);

rHA = mkrPos.('RANK')(index,:)-mkrPos.('RHEE')(index,:);
eHA = rHA./norm(rHA);

ex = eHA-(eHA*ey').*ey;
ex = ex./norm(ex);

ez = cross(ex,ey);

r = (mkrPos.('RHEE')(index,:) + (rHA*ey').*ey)';

if( ~(ex*ey' < 1e-6) )
  here=1;
end

assert(ex*ey' < 1e-6);
assert(ex*ez' < 1e-6);

assert( abs(ex*ex'-1) < 1e-6);
assert( abs(ey*ey'-1) < 1e-6);
assert( abs(ez*ez'-1) < 1e-6);

%Right frame desired orientation

eyD = ey;
eyD(1,3) = 0;
eyD = eyD./norm(eyD);

exD = ex;
exD(1,3) = 0;
exD = exD - (exD*eyD')*eyD;
exD = exD./norm(exD);


ezD = cross(exD,eyD);

assert(exD*eyD' < 1e-6);
assert(exD*ezD' < 1e-6);

assert( abs(exD*exD'-1) < 1e-6);
assert( abs(eyD*eyD'-1) < 1e-6);
assert( abs(ezD*ezD'-1) < 1e-6);

%Offset
frameRightOffset.E = ([ex',ey',ez']')*[exD',eyD',ezD'];
frameRightOffset.r = [0;0;-r(3,1)];

%Left frame
ey = mkrPos.('LTOE')(index,:)-mkrPos.('LHEE')(index,:);
ey = ey./norm(ey);

rHA = mkrPos.('LANK')(index,:)-mkrPos.('LHEE')(index,:);
eHA = rHA./norm(rHA);

ex = -(eHA-(eHA*ey').*ey);
ex = ex./norm(ex);

ez = cross(ex,ey);

r = (mkrPos.('LHEE')(index,:) + (rHA*ey').*ey)';

assert(ex*ey' < 1e-6);
assert(ex*ez' < 1e-6);

assert( abs(ex*ex'-1) < 1e-6);
assert( abs(ey*ey'-1) < 1e-6);
assert( abs(ez*ez'-1) < 1e-6);

%Left frame desired orientation
eyD = ey;
eyD(1,3) = 0;
eyD = eyD./norm(eyD);

exD = ex;
exD(1,3) = 0;
exD = exD - (exD*eyD')*eyD;
exD = exD./norm(exD);


ezD = cross(exD,eyD);

assert(exD*eyD' < 1e-6);
assert(exD*ezD' < 1e-6);

assert( abs(exD*exD'-1) < 1e-6);
assert( abs(eyD*eyD'-1) < 1e-6);
assert( abs(ezD*ezD'-1) < 1e-6);


frameLeftOffset.E = ([ex',ey',ez']')*[exD',eyD',ezD'];
frameLeftOffset.r = [0;0;-r(3,1)];



