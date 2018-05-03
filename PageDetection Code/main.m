close all;
%% Load videframes
ImagePath='./images/myImage.jpg';
v = VideoReader('..\page-detection\background01\datasheet001.avi');
numberFrames=v.Duration*v.FrameRate;

%% Load ground truth of XML
XMLStruct= parseXML('..\page-detection\background01\datasheet001.gt.xml');
GroundTruthFrames=XMLStruct.Children(6).Children(2:2:numberFrames*2);
% GroundTruth =[Frame,Zeilen X,Y, Spalte 1-4]
GroundTruth= zeros(2,4,numberFrames);
for i=1:numberFrames
    for j=2:2:8
        GroundTruth(1,j/2,i)= str2double(GroundTruthFrames(i).Children(j).Attributes(2).Value);
        GroundTruth(2,j/2,i)=str2double(GroundTruthFrames(i).Children(j).Attributes(3).Value);
    end
end

frameNr=2;
%for frameNr=1:numberFrames
    
    vImage=read(v,frameNr);
    imwrite(vImage,ImagePath);

    %% Calculate BestBoundingBox
    bestBoundingBox=detectPage(ImagePath);


    %% Calculate Jacard Index
    areaBB=poly2mask(bestBoundingBox(1,:),bestBoundingBox(2,:),v.Height,v.Width);
    areaGT=poly2mask(GroundTruth(1,:,frameNr),GroundTruth(2,:,frameNr),v.Height,v.Width);
    intersection= areaBB & areaGT;
    union= areaBB | areaGT;
    jacardIndex(frameNr)=sum(sum(int8(intersection)))/sum(sum(int8(union)));
%end

