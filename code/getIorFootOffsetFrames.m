function [frameLeftOffset, frameRightOffset]=...
        getIorFootOffsetFrames(index, mkrPos)


frameRightOffset = struct('r',zeros(3,1),'E',zeros(3,3));
frameLeftOffset  = struct('r',zeros(3,1),'E',zeros(3,3));

%Right frame
r = (1/2).*(...%mkrPos.('R_FCC')(index,:)'...
          + mkrPos.('R_FAL')(index,:)'...
          + mkrPos.('R_TAM')(index,:)');
                   

ey = 0.5.*(mkrPos.('R_FM1')(index,:)+mkrPos.('R_FM5')(index,:)) ...
        - mkrPos.('R_FCC')(index,:); 
ey = ey./norm(ey);

ex = mkrPos.('R_FAL')(index,:) - mkrPos.('R_TAM')(index,:);
ex = ex - sum(ey.*ex).*ey;
ex = ex./norm(ex);

ez = cross(ex,ey);

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
r = (1/2).*(...%mkrPos.('L_FCC')(index,:)'...
          + mkrPos.('L_FAL')(index,:)'...
          + mkrPos.('L_TAM')(index,:)');
                   

ey = 0.5.*(mkrPos.('L_FM1')(index,:)+mkrPos.('L_FM5')(index,:)) ...
        - mkrPos.('L_FCC')(index,:); 
ey = ey./norm(ey);

ex = mkrPos.('L_TAM')(index,:) - mkrPos.('L_FAL')(index,:);
ex = ex - sum(ey.*ex).*ey;
ex = ex./norm(ex);

ez = cross(ex,ey);

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



