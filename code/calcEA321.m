function ea321 = calcEA321(R01)
%%
% This function extracts the three 3-2-1 Euler angles that 
% encode the rotation matrix R01 
%
% @param R01M
%        A 3 x 3 matrix. Each row is a rotation matrix that has been 
%        sampled row-wise.
%
% @return ea321M
%        A 1 x 3 matrix of 3-2-1 Euler angles. This matrix has the
%        columns
%
%       Column :  1          2          3
%       Name   :  psiZ       thetaY     phiX
%%

ea321 = zeros(1 ,3);

epsRoot = eps^0.5;



%Extract angle 1
ea321(1,3) =  atan2(R01(3,2), R01(3,3));

%Extract angle 2
cosBeta = (R01(1,1)*R01(1,1) + R01(2,1)*R01(2,1))^0.5;
ea321(1,2) = atan2(-R01(3,1), cosBeta);

%Extracting the third angle is a bit more complicated
%1. We have R01 = R(psiZ,z)*R(thetaY,y)*R(phiX,x)
%   and we've got phiX, and thetaY but we don't know psiZ
%
%2. If we multiply both sides from the right by R(phiX,x)' R(thetaY,y)'
%   (where ' is a transpose), we are left with
%    
%    R01*R(phiX,x)'*R(thetaY,y)' = R(psiZ,z)
%
%    Really - if you multiply R01 on the right by R(phiX,x)' and
%    R(thetaY,y)' you're left with an elementary rotation matrix
%    about the z axis, and by now you can get the angle of this 
%    matrix pretty easily.



s1 = sin(ea321(1,3));
c1 = cos(ea321(1,3));    
r1 = [1 0 0; 0 c1 -s1; 0 s1 c1];

s2 = sin(ea321(1,2));
c2 = cos(ea321(1,2));
r2 = [c2 0 s2; 0 1 0; -s2 0 c2];

r3 = R01*r1'*r2';
ea321(1,1) = atan2( r3(2,1), r3(1,1));

s3 = sin(ea321(1,1));
c3 = cos(ea321(1,1));
r3 = [c3 -s3 0; s3 c3 0; 0 0 1];

%%
%Check
%%
eM = R01 - r3*r2*r1;
err = norm(eM);
if (err > epsRoot)
   disp('EA321 decomposition failed: thetaY is likely 90 degrees'); 
end
