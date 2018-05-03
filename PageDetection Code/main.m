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

for i=1:backgroundNumber
    for j=1:2:fileNumber
        resultJacardIndices(j,i) = detectPageInVideo( videoPath{j,i},videoPath{j+1,i});
    end
end