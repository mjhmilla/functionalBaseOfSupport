%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function figH = plotExportConfig(figH,pageWidth,pageHeight)
figure(figH);
set(gcf, 'InvertHardCopy', 'off');
set(gcf,'Units','centimeters',...
   'PaperUnits','centimeters',...
   'PaperSize',[pageWidth pageHeight],...
   'PaperPositionMode','manual',...
   'PaperPosition',[0 0 pageWidth pageHeight]);      
set(gcf,'renderer','painters');     
