%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

function dataStruct = readCsvConvertToStruct(fileName)

fid =fopen(fileName,'r');
header = fgetl(fid);
fclose(fid);

data = dlmread(fileName,',',1,0);

idx0=1;
delimiterIndices = strfind(header,',');
idx1=delimiterIndices(1,1);
columnCount=0;
columnName = '';

for i=1:1:(length(delimiterIndices)+1)
    if( i > length(delimiterIndices)-3)
        here=1;
    end

    if(i==1)
        idx0=1;
        idx1=delimiterIndices(1,i);    
    elseif(i <= length(delimiterIndices))
        idx0=idx1+1;
        idx1=delimiterIndices(1,i);
    else
        idx0=idx1+1;
        idx1=length(header);
    end

    if(idx1-1-idx0 > 0)
        if(i <= length(delimiterIndices))
            substr = header(idx0:(idx1-1));    
        else
            substr = header(idx0:(idx1));        
        end
    else
        substr = '';
    end
    columnCount=1+columnCount;

    if(isempty(substr) == 0)
        columnName=substr;        
        dataColumns.(columnName) = [];
        dataColumns.(columnName) = ...
            [dataColumns.(columnName),columnCount];
    else
        if(isempty(columnName) == 0)
            dataColumns.(columnName) = ...
                [dataColumns.(columnName),columnCount];
        end
    end
end

subFields=fields(dataColumns);

for i=1:1:length(subFields)
    columns = dataColumns.(subFields{i});    
    dataStruct.(subFields{i}) = data(:,columns);
end