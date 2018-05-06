%% Page Detection 
% Timon Höbert 01427936
% Manuel Mayerhofer 01328948
% Stefan Stappen 01329020

function [ jacardIndex ] = detectPageInVideo( videoPath,xmlPath )
%% input
%  videoPath e.g...\page-detection\background01\datasheet001.avi
%  xmlPath e.g...\page-detection\background01\datasheet001.gt.xml

%% output
%  jacardIndex of the video := Average of the frame jacardindices
    
%% init
stepSize = 5;

%% Load videframes

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
%     vImage=read(v,161);
%     detectPage(vImage);
% %%%%%%%%%%%%%%



for frameNr=1:stepSize:numberFrames
    vImage=read(v,frameNr);

    %% Calculate BestBoundingBox
    [boundingBoxesVideo(:,:,frameNr),areaBBVideo(frameNr)]=detectPage(vImage);
end

%% Interpolate between Frames
averageArea=0;
counter=0;

interpolation=true;

if(interpolation)
    for i=1:stepSize:length(boundingBoxesVideo)
        if areaBBVideo(i)~=0
            counter=counter+1;
            averageArea=averageArea+areaBBVideo(i);
        end
    end
    averageArea=averageArea/counter;
    
    tempBB= zeros(2,4,2);
    
    for frameNr=1:numberFrames 
        if frameNr==17
            hi=0;
        end
        if(areaBBVideo(frameNr)<averageArea*0.7)
            for i=frameNr+1:numberFrames
                 if(areaBBVideo(i)>averageArea*0.7)
                     tempBB(:,:,1)=boundingBoxesVideo(:,:,i);
                     break;
                 end
            end
            for i=frameNr-1:-1:1
             if(areaBBVideo(i)>averageArea*0.7)
                 tempBB(:,:,2)=boundingBoxesVideo(:,:,i);
                 break;
             end
            end
            if tempBB(:,:,2) ==0 |tempBB(:,:,1)==0
                boundingBoxesVideo(:,:,frameNr)=tempBB(:,:,1)+tempBB(:,:,2);
            else
                temp=zeros(1,4);
                temp(1)=sum(sum(abs(tempBB(:,:,1)-tempBB(:,:,2))));
                temp(2)=sum(sum(abs(tempBB(:,:,1)-circshift(tempBB(:,:,2), -1, 2))));
                temp(3)=sum(sum(abs(tempBB(:,:,1)-circshift(tempBB(:,:,2), -2, 2))));
                temp(4)=sum(sum(abs(tempBB(:,:,1)-circshift(tempBB(:,:,2), -3, 2))));
                [value,index]=min(temp);
                boundingBoxesVideo(:,:,frameNr)=(tempBB(:,:,1)+circshift(tempBB(:,:,2), -index+1, 2))/2;
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
    %[double(1:stepSize:numberFrames); jacardIndexFrames(1:stepSize:numberFrames)']'
end

