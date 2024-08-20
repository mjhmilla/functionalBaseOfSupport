%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

function [frameLeft, frameRight]= getIorFootFrames(index, mkrPos,...
                                        frameLeftOffset, frameRightOffset)


frameRight = struct('r',zeros(3,1),'E',zeros(3,3));
frameLeft  = struct('r',zeros(3,1),'E',zeros(3,3));

if(isfield(mkrPos,'R_FAL'))

    frameRight.r = (1/2).*(...%mkrPos.('R_FCC')(index,:)'...
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
    
    %Offset
    frameRight.E = [ex', ey', ez']*frameRightOffset.E;
    
    frameRight.r = frameRight.r + frameRight.E*frameRightOffset.r;

end

if(isfield(mkrPos,'L_FAL'))

    frameLeft.r = (1/2).*(...%mkrPos.('L_FCC')(index,:)'...
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
    
    frameLeft.E = [ex', ey', ez']*frameLeftOffset.E;
    frameLeft.r = frameLeft.r + frameLeft.E*frameLeftOffset.r;

end


