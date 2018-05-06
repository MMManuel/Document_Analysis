%% Page Detection 
% Timon Höbert 01427936
% Manuel Mayerhofer 01328948
% Stefan Stappen 01329020

function  newLines  = mergeLines( lines, margin )
%MERGELINES merge lines within pixel margin. 
% All lines sharing a common endpoint within a circular marign are merged
% returns the merged and reduced set of lines
numLines = size(lines,2);

for hLines=1:size(lines,2)
      
    if lines(5, hLines) == 0 continue; end
 
    found = 1;
    
    foundLines = [lines(:, hLines)];
    prevEqual = false(1,size(lines, 2));
    prevEqual(hLines) = 1;
    
    
    while found <= size(foundLines,2)
       x1_1Equal = repmat(foundLines(1, found) - margin, 1, numLines)  <= lines(1, :) ...
                & repmat(foundLines(1, found) + margin, 1, numLines)  >= lines(1, :);
       x1_2Equal = repmat(foundLines(1, found) - margin, 1, numLines)  <= lines(2, :) ...
                & repmat(foundLines(1, found) + margin, 1, numLines)  >= lines(2, :);
       x2_1Equal = repmat(foundLines(2, found) - margin, 1, numLines)  <= lines(1, :) ...
                & repmat(foundLines(2, found) + margin, 1, numLines)  >= lines(1, :);
       x2_2Equal = repmat(foundLines(2, found) - margin, 1, numLines)  <= lines(2, :) ...
                & repmat(foundLines(2, found) + margin, 1, numLines)  >= lines(2, :);
            
       y1_1Equal = repmat(foundLines(3, found) - margin, 1, numLines)  <= lines(3, :) ...
                & repmat(foundLines(3, found) + margin, 1, numLines)  >= lines(3, :);
       y1_2Equal = repmat(foundLines(3, found) - margin, 1, numLines)  <= lines(4, :) ...
                & repmat(foundLines(3, found) + margin, 1, numLines)  >= lines(4, :);
       y2_1Equal = repmat(foundLines(4, found) - margin, 1, numLines)  <= lines(3, :) ...
                & repmat(foundLines(4, found) + margin, 1, numLines)  >= lines(3, :);
       y2_2Equal = repmat(foundLines(4, found) - margin, 1, numLines)  <= lines(4, :) ...
                & repmat(foundLines(4, found) + margin, 1, numLines)  >= lines(4, :);
            
       equal = x1_1Equal & y1_1Equal | x1_2Equal & y1_2Equal ...
           | x2_1Equal & y2_1Equal | x2_2Equal & y2_2Equal;

        found = found + 1;
        
        foundLines = [foundLines, lines(:, equal & ~prevEqual)];
        
        prevEqual = prevEqual | equal;
    end
    
    % sets all found to zero so they are not found again
    lines(:, prevEqual) = zeros(size(lines,1), sum(prevEqual));
    
    [minX1, minX1I] = min(foundLines(1,:));
    [minX2, minX2I] = min(foundLines(2,:));
    
    [minX, minXI] = min([minX1, minX2]);
    minXI_R = (1-(minXI-1)) * minX1I + (minXI-1) * minX2I;
    minY = min(foundLines(minXI + 2,minXI_R));
    
    [maxX1, maxX1I] = max(foundLines(1,:));
    [maxX2, maxX2I] = max(foundLines(2,:));
    
    [maxX, maxXI] = max([maxX1, maxX2]);
    maxXI_R = (1-(maxXI-1)) * maxX1I + (maxXI-1) * maxX2I;
    maxY = max(foundLines(maxXI + 2,maxXI_R));
    
    lines(:, hLines) =  [minX maxX minY maxY max(foundLines(5,:))];
    %[min(min(foundLines(1,:)),min(foundLines(2,:))) max(max(foundLines(1,:)),max(foundLines(2,:)))...
    %     min(min(foundLines(3,:)),min(foundLines(4,:))) max(max(foundLines(3,:)),max(foundLines(4,:))) max(foundLines(5,:))];
    
end

newLines = lines(:, lines(5,:) ~= 0);

end

