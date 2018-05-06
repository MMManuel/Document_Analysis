%% Page Detection 
% Timon Höbert 01427936
% Manuel Mayerhofer 01328948
% Stefan Stappen 01329020

close all;

fileNumber=60;
backgroundNumber=5;

videoPath=cell(fileNumber,backgroundNumber);

for i=1:backgroundNumber
    folderPath=strcat('..\page-detection\background0',int2str(i));
    folder= dir(folderPath);
    for j = 3 : size(folder, 1)
        videoPath{j-2,i}=strcat(folderPath,'\',folder(j).name);
    end
end

%resultJacardIndices := column= background JIs: 30x5   
resultJacardIndices= zeros(fileNumber/2,backgroundNumber);

% detectPageInVideo('..\page-detection\background01\datasheet003.avi','..\page-detection\background01\datasheet003.gt.xml')

i=5;
% for i=1:backgroundNumber
   for j=1:2:fileNumber
        resultJacardIndices(j,i) = detectPageInVideo( videoPath{j,i},videoPath{j+1,i});
    end
% end