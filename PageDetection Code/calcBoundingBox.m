function boundingBox = calcBoundingBox(hLine1,hLine2,vLine1,vLine2)
%calcBoundingBox([2;4;2;2],[2;4;5;5],[1;1;3;4],[5;5;3;4])
% calculates the intersection of 2 horizontal and 2 vertical Lines that form a bounding box
%% input
%  hLine1: [X1;X2;Y1;Y2] columvector
%  hLine2: [X1;X2;Y1;Y2] columvector
%  vLine1: [X1;X2;Y1;Y2] columvector
%  vLine2: [X1;X2;Y1;Y2] columvector
%% output
%  | X1  X2  X3  X4 | 
%  | Y1  Y2  Y3  Y4 |

boundingBox=[0,0,0,0; 0,0,0,0];
%Linecrossing hLine1/vLine1
intersectionPoint1=lineintersect(vertcat(hLine1(1:2),vLine1(1:2)),vertcat(hLine1(3:4),vLine1(3:4)));
    if(~isfinite(intersectionPoint1(1)))
        return;
    end
%Linecrossing hLine1/vLine2
intersectionPoint2=lineintersect(vertcat(hLine1(1:2),vLine2(1:2)),vertcat(hLine1(3:4),vLine2(3:4)));
    if(~isfinite(intersectionPoint2(1)))
        return;
    end
%Linecrossing hLine2/vLine1
intersectionPoint3=lineintersect(vertcat(hLine2(1:2),vLine1(1:2)),vertcat(hLine2(3:4),vLine1(3:4)));
    if(~isfinite(intersectionPoint3(1)))
        return;
    end
%Linecrossing hLine2/vLine2
intersectionPoint4=lineintersect(vertcat(hLine2(1:2),vLine2(1:2)),vertcat(hLine2(3:4),vLine2(3:4)));
    if(~isfinite(intersectionPoint4(1)))
        return;
    end


%return boundingBox
boundingBox=horzcat(intersectionPoint1,intersectionPoint2,intersectionPoint3,intersectionPoint4);

end

function point = lineintersect(x,y)
% calculate intersection point of two 2d lines specified with 2 points each
% (X1, Y1; X2, Y2; X3, Y3; X4, Y4), while 1&2 and 3&4 specify a line.
% Gives back NaN or Inf/-Inf if lines are parallel (= when denominator = 0)
% see http://en.wikipedia.org/wiki/Line-line_intersection    
    % Calculation
    denominator = (x(1)-x(2))*(y(3)-y(4))-(y(1)-y(2))*(x(3)-x(4));
    point = [((x(1)*y(2)-y(1)*x(2))*(x(3)-x(4))-(x(1)-x(2))*(x(3)*y(4)-y(3)*x(4)))/denominator ...
        ;((x(1)*y(2)-y(1)*x(2))*(y(3)-y(4))-(y(1)-y(2))*(x(3)*y(4)-y(3)*x(4)))/denominator];
    
end