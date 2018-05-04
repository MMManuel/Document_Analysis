function [ jacardIndex ] = detectPageInVideo( videoPath,xmlPath )
%% input
%  videoPath e.g...\page-detection\background01\datasheet001.avi
%  xmlPath e.g...\page-detection\background01\datasheet001.gt.xml

%% output
%  jacardIndex of the video := Average of the frame jacardindices
    
%% init
stepSize = 20;

%% Load videframes
imagePath='./images/myImage.jpg';
v = VideoReader(videoPath);
numberFrames=int16(v.Duration*v.FrameRate);

%% Load ground truth of XML
XMLStruct= parseXML(xmlPath);
GroundTruthFrames=XMLStruct.Children(6).Children(2:2:numberFrames*2);
% GroundTruth =[Frame,Zeilen X,Y, Spalte 1-4]
GroundTruth= zeros(2,4,numberFrames);
for i=1:numberFrames
    for j=2:2:8
        GroundTruth(1,j/2,i)= str2double(GroundTruthFrames(i).Children(j).Attributes(2).Value);
        GroundTruth(2,j/2,i)=str2double(GroundTruthFrames(i).Children(j).Attributes(3).Value);
    end
end

boundingBoxesVideo= zeros(2,4,numberFrames/stepSize);
areaBBVideo=zeros(numberFrames/stepSize);


%%%%%%%%%%%%
    vImage=read(v,22);
    imwrite(vImage,imagePath);
    detectPage(imagePath);
%%%%%%%%%%%%%%



for frameNr=1:stepSize:numberFrames
    
    vImage=read(v,frameNr);
    imwrite(vImage,imagePath);

    %% Calculate BestBoundingBox
    
    [boundingBoxesVideo(:,:,round(frameNr/stepSize)+1),angleOfMaxArea,maxArea(round(frameNr/stepSize)+1)]=detectPage(imagePath);
end

 %% Calculate Jacard Index
    jacardIndexFrames= zeros(frameNr/stepSize,1);
    for frameNr=1:stepSize:numberFrames
        index = round(frameNr/stepSize)+1;
        areaBB=poly2mask(boundingBoxesVideo(1,:,index),boundingBoxesVideo(2,:,index),v.Height,v.Width);
        areaGT=poly2mask(GroundTruth(1,:,frameNr),GroundTruth(2,:,frameNr),v.Height,v.Width);
        intersection= areaBB & areaGT;
        union= areaBB | areaGT;
        jacardIndexFrames(index)=sum(sum(int8(intersection)))/sum(sum(int8(union)));
    end
    
    
    
    %Average the jacardIndex over the frames
    jacardIndex=0;
    jacardIndex=sum(jacardIndexFrames)/length(jacardIndexFrames);

    disp([videoPath ' ' num2str(jacardIndex)])
    [double(1:stepSize:numberFrames); jacardIndexFrames']'
end

