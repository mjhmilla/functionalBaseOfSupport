function polygonArcLength = calcPolygonArcLength(polygonXY)

polygonArcLength=zeros(size(polygonXY,1),1);

for i=2:1:size(polygonXY,1)
    lineSegment = polygonXY(i,:)-polygonXY(i-1,:);
    polygonArcLength(i,1) = polygonArcLength(i-1,1) ...
                           +sqrt(lineSegment*lineSegment'); 
end

