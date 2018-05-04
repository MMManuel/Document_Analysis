function [ jacardIndex ] = detectPageInVideo( videoPath,xmlPath )
%% input
%  videoPath e.g...\page-detection\background01\datasheet001.avi
%  xmlPath e.g...\page-detection\background01\datasheet001.gt.xml

%% output
%  jacardIndex of the video := Average of the frame jacardindices
    
%% init
stepSize = 2;

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

boundingBoxesVideo= zeros(2,4,numberFrames);
areaBBVideo=zeros(numberFrames,1);


%%%%%%%%%%%%
%     vImage=read(v,202);
%     imwrite(vImage,imagePath);
%     detectPage(imagePath);
%%%%%%%%%%%%%%



for frameNr=1:stepSize:numberFrames
    
    vImage=read(v,frameNr);
    imwrite(vImage,imagePath);

    %% Calculate BestBoundingBox
    [boundingBoxesVideo(:,:,frameNr),areaBBVideo(frameNr)]=detectPage(imagePath);
end

%% Interpolate between Frames
averageArea=0;
counter=0;


for i=1:stepSize:length(boundingBoxesVideo)
    if areaBBVideo(i)~=0
        counter=counter+1;
        averageArea=averageArea+areaBBVideo(i);
    end
end
averageArea=averageArea/counter;

for frameNr=1:numberFrames 
    if frameNr==221
    hi=0;
    end
    atTheEnd=true;
    if(areaBBVideo(frameNr)<averageArea*0.7)
        for i=frameNr+1:numberFrames
             if(areaBBVideo(i)>averageArea*0.7)
                 boundingBoxesVideo(:,:,frameNr)=boundingBoxesVideo(:,:,i);
                 atTheEnd=false;
                 break;
             end
        end
        %if the last ones habe no values go in the other direction
        if atTheEnd
            for i=frameNr-1:-1:1
             if(areaBBVideo(i)>averageArea*0.7)
                 boundingBoxesVideo(:,:,frameNr)=boundingBoxesVideo(:,:,i);
                 break;
             end
        end
        end
    end
end

 %% Calculate Jacard Index
    jacardIndexFrames= zeros(frameNr,1);
    for frameNr=1:numberFrames
        areaBB=poly2mask(boundingBoxesVideo(1,:,frameNr),boundingBoxesVideo(2,:,frameNr),v.Height,v.Width);
        areaGT=poly2mask(GroundTruth(1,:,frameNr),GroundTruth(2,:,frameNr),v.Height,v.Width);
        intersection= areaBB & areaGT;
        union= areaBB | areaGT;
        jacardIndexFrames(frameNr)=sum(sum(int8(intersection)))/sum(sum(int8(union)));
    end
    
    
    
    %Average the jacardIndex over the frames
    jacardIndex=0;
    jacardIndex=sum(jacardIndexFrames)/length(jacardIndexFrames);

    disp([videoPath ' ' num2str(jacardIndex)])
    [double(1:1:numberFrames); jacardIndexFrames']'
end

