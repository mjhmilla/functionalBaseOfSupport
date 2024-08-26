%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

function [footLengthPig, midFootLengthPig, footWidthPig] = getPigFootSize(idxRef,...
                frameLeft, frameRight, ...
                ratio_MidFootLengthIor_MidFootLengthPig,...
                ratio_FootLengthIor_MidFootLengthIor,...
                ratio_FootWidthIor_MidFootLengthIor,...
                c3dMarkersRef)



 rLenL = frameLeft.E'*(...
           c3dMarkersRef.('LTOE')(idxRef,:)' ...
          -c3dMarkersRef.('LHEE')(idxRef,:)');         
 midFootLengthL = rLenL(2,1);

 midFootLengthIorL = midFootLengthL*ratio_MidFootLengthIor_MidFootLengthPig;

 rLenR = frameRight.E'*frameLeft.E'*(...
           c3dMarkersRef.('RTOE')(idxRef,:)' ...
          -c3dMarkersRef.('RHEE')(idxRef,:)');          

 midFootLengthR = rLenR(2,1);
 midFootLengthIorR = midFootLengthR*ratio_MidFootLengthIor_MidFootLengthPig;
 
 midFootLengthPig = 0.5*(midFootLengthIorL+midFootLengthIorR);
        

 footLengthL    = midFootLengthIorL*ratio_FootLengthIor_MidFootLengthIor;      

 footLengthR    = midFootLengthIorR*ratio_FootLengthIor_MidFootLengthIor; 

 footLengthPig     = 0.5*(footLengthL+footLengthR);


 footWidthIorL = midFootLengthIorL*ratio_FootWidthIor_MidFootLengthIor;      
 footWidthIorR = midFootLengthIorR*ratio_FootWidthIor_MidFootLengthIor;
 footWidthPig  = 0.5*(footWidthIorL+footWidthIorR);

