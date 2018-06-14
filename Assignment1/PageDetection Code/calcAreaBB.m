%% Page Detection 
% Timon Höbert 01427936
% Manuel Mayerhofer 01328948
% Stefan Stappen 01329020
function area = calcAreaBB(BB)
area =polyarea(BB(1,:),BB(2,:));
end