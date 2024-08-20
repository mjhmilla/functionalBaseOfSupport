%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

function bosTransformed = transformBosModel(bos,frame)

bosTransformed = zeros(size(bos,1),3);

for i=1:1:size(bos,1)
    bosTransformed(i,:) =  frame.r' + (frame.E(:,1).*bos(i,1) ...
                                     + frame.E(:,2).*bos(i,2))'; 

end