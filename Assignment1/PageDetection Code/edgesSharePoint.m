%% Page Detection 
% Timon H�bert 01427936
% Manuel Mayerhofer 01328948
% Stefan Stappen 01329020

function sharePoint = edgesSharePoint( line1, line2, margin )
%EDGESSHAREPOINT 
% computes if two edges share a common point within margin
 x1_1Equal = line1(1) - margin  <= line2(1) ...
                & line1(1) + margin  >= line2(1);
x1_2Equal = line1(1) - margin  <= line2(2) ...
        & line1(1) + margin  >= line2(2);
x2_1Equal = line1(2) - margin  <= line2(1) ...
        & line1(2) + margin  >= line2(1);
x2_2Equal = line1(2) - margin  <= line2(2) ...
        & line1(2) + margin  >= line2(2);

y1_1Equal = line1(3) - margin  <= line2(3) ...
        & line1(3) + margin  >= line2(3);
y1_2Equal = line1(3) - margin  <= line2(4) ...
        & line1(3) + margin  >= line2(4);
y2_1Equal = line1(4) - margin  <= line2(3) ...
        & line1(4) + margin  >= line2(3);
y2_2Equal = line1(4) - margin  <= line2(4) ...
        & line1(4) + margin  >= line2(4);
            
       sharePoint = x1_1Equal & y1_1Equal | x1_2Equal & y1_2Equal ...
           | x2_1Equal & y2_1Equal | x2_2Equal & y2_2Equal;

end

