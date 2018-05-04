% ImagePath='./images/myImage.jpg';
% v = VideoReader('..\page-detection\background01\datasheet002.avi');
% vImage=read(v,21);
% imwrite(vImage, ImagePath);

function [ bestBoundingBox,maxArea ] = detectPage( ImagePath )
%% parameters

margin = 10;
quadMargin = 50;
maxLength = 3000;
maxAreaPercentage = 0.20;
minLengthPercentage = 0.10;

image = imread(ImagePath);
image = rgb2gray(image);

image = edge(image, 'canny');
% se = strel('line',5,90);
% image = imdilate(image, se);
% image = imdilate(image, se);
% image = imdilate(image, se);
% image = imerode(image, se);
% image = imerode(image, se);
% image = imerode(image, se);



%% get the start_points and end_points of each straight line use LSD.
lines = lsd(ImagePath);

 

img_width=size(image,2);
img_height=size(image,1);
length=(lines(1,:)-lines(2,:)).^2+(lines(3,:)-lines(4,:)).^2;
indices=find(length> ( img_width + img_height)/2 * minLengthPercentage & ...                                              %length removal
    lines(1,:)<img_width*0.8 & lines(1,:)>img_width*0.2 & ...      %surrounding x1 removal
    lines(2,:)<img_width*0.8 & lines(2,:)>img_width*0.2 & ...      %surrounding x2 removal
    lines(3,:)<img_height*0.9 & lines(3,:)>img_height*0.1 & ...    %surrounding y1 removal
    lines(4,:)<img_height*0.9 & lines(4,:)>img_height*0.1);        %surrounding y2 removal
lines=lines(:,indices);


%plotOriginalLines(image,lines)

% group lines
indicesVertical=find(abs(lines(1,:)-lines(2,:))./abs(lines(3,:)-lines(4,:))<1);
indicesHorizontal=find(abs(lines(1,:)-lines(2,:))./abs(lines(3,:)-lines(4,:))>1);
linesVertical=lines(:,indicesVertical);
linesHorizontal=lines(:,indicesHorizontal);

%% mergelines

linesVertical = mergeLines(linesVertical, margin);
linesHorizontal = mergeLines(linesHorizontal, margin);

%% discard lines
length=(linesVertical(1,:)-linesVertical(2,:)).^2+(linesVertical(3,:)-linesVertical(4,:)).^2;
indices=find(length>maxLength);        %surrounding y2 removal
linesVertical=linesVertical(:,indices);

length=(linesHorizontal(1,:)-linesHorizontal(2,:)).^2+(linesHorizontal(3,:)-linesHorizontal(4,:)).^2;
indices=find(length>maxLength);        %surrounding y2 removal
linesHorizontal=linesHorizontal(:,indices);

%plotReducedLines(image,linesHorizontal,linesVertical);

%% compute bounding boxes

boundingBoxes = [];
i = 0;
for hLines1=1:size(linesHorizontal,2)
    for hLines2=hLines1+1:size(linesHorizontal,2)
        for vLines1=1:size(linesVertical,2)
            for vLines2=vLines1+1:size(linesVertical,2)
                hLine1 = linesHorizontal(1:4,hLines1);
                hLine2 = linesHorizontal(1:4,hLines2);
                vLine1 = linesVertical(1:4,vLines1);
                vLine2 = linesVertical(1:4,vLines2);
                 
                minXV1 = min(min(vLine1(1),vLine1(2)),min(vLine2(1),vLine2(2)));
                maxXV2 = max(max(vLine1(1),vLine1(2)),max(vLine2(1),vLine2(2)));
                
                minYH1 = min(min(hLine1(3),hLine1(4)),min(hLine2(3),hLine2(4)));
                maxYH2 = max(max(hLine1(3),hLine1(4)),max(hLine2(3),hLine2(4)));
                
                if hLine1(1) < minXV1 && hLine1(2) < minXV1  || ... % both x coords are smaller than min x, edge is outside of vertical lines
                        hLine1(1) > maxXV2 && hLine1(2) > maxXV2 || ...
                        hLine2(1) < minXV1 && hLine2(2) < minXV1  || ... 
                        hLine2(1) > maxXV2 && hLine2(2) > maxXV2 || ...
                        vLine1(3) < minYH1 && vLine1(4) < minYH1  || ... % both y coords are smaller than min y, edge is outside of horizontal lines
                        vLine1(3) > maxYH2 && vLine1(4) > maxYH2 || ...
                        vLine2(3) < minYH1 && vLine2(4) < minYH1  || ... 
                        vLine2(3) > maxYH2 && vLine2(4) > maxYH2
                        continue;
                end
                sharePointh1v1=edgesSharePoint(hLine1, vLine1, quadMargin);
                sharePointh1v2=edgesSharePoint(hLine1, vLine2, quadMargin);
                sharePointh2v1=edgesSharePoint(hLine2, vLine1, quadMargin);
                sharePointh2v2=edgesSharePoint(hLine2, vLine2, quadMargin);

                if (sharePointh1v1 & sharePointh1v2 & sharePointh2v1 |... 
                    sharePointh1v1 & sharePointh1v2 & sharePointh2v2 |...
                    sharePointh1v1 & sharePointh2v1 & sharePointh2v2 |...
                    sharePointh1v2 & sharePointh2v1 & sharePointh2v2)
                         i = i+1;
                        boundingBoxes(:, :,i) = calcBoundingBox(hLine1,hLine2,vLine1,vLine2);
                end
            end
        end
    end
end

if size(boundingBoxes, 1) == 0
   i = 0;
    for hLines1=1:size(linesHorizontal,2)
        for hLines2=hLines1+1:size(linesHorizontal,2)
            for vLines1=1:size(linesVertical,2)
                for vLines2=vLines1+1:size(linesVertical,2)
                    hLine1 = linesHorizontal(1:4,hLines1);
                    hLine2 = linesHorizontal(1:4,hLines2);
                    vLine1 = linesVertical(1:4,vLines1);
                    vLine2 = linesVertical(1:4,vLines2);
                    
                    minXV1 = min(min(vLine1(1),vLine1(2)),min(vLine2(1),vLine2(2)));
                    maxXV2 = max(max(vLine1(1),vLine1(2)),max(vLine2(1),vLine2(2)));

                    minYH1 = min(min(hLine1(3),hLine1(4)),min(hLine2(3),hLine2(4)));
                    maxYH2 = max(max(hLine1(3),hLine1(4)),max(hLine2(3),hLine2(4)));
                    
                     if hLine1(1) < minXV1 && hLine1(2) < minXV1  || ... % both x coords are smaller than min x, edge is outside of vertical lines
                        hLine1(1) > maxXV2 && hLine1(2) > maxXV2 || ...
                        hLine2(1) < minXV1 && hLine2(2) < minXV1  || ... 
                        hLine2(1) > maxXV2 && hLine2(2) > maxXV2 || ...
                        vLine1(3) < minYH1 && vLine1(4) < minYH1  || ... % both y coords are smaller than min y, edge is outside of horizontal lines
                        vLine1(3) > maxYH2 && vLine1(4) > maxYH2 || ...
                        vLine2(3) < minYH1 && vLine2(4) < minYH1  || ... 
                        vLine2(3) > maxYH2 && vLine2(4) > maxYH2
                        continue;
                    end
                    
                    i = i+1;
                    boundingBoxes(:, :,i) = calcBoundingBox(hLine1,hLine2,vLine1,vLine2);
                end
            end
        end

    end
end

%plotBBs(image,boundingBoxes)

% choose best quad
maxArea = 0;
bestBoundingBox = zeros(2,4);
areaLimit = img_width * img_height * maxAreaPercentage;

%No Bounding Box Found
if isempty(boundingBoxes)
    disp('error, no bb')
    return;
end

for i = 1:size(boundingBoxes,3)
    if i==5
    hi=0;
    end
    % reorder corner points
    boundingBox = boundingBoxes(:, :,i);
    %plotBB(image,boundingBox,linesHorizontal,linesVertical);
    [order,area]=convhull(boundingBox(1,:),boundingBox(2,:));
    %boundingBox points in counterclockwise order
    boundingBox=horzcat(boundingBox(:,order(1)),boundingBox(:,order(2)),boundingBox(:,order(3)),boundingBox(:,order(4)));
    
    
    %check if horizontal lines have equal length also vertical lines
    lengthHorz1=sqrt(((boundingBox(1,1)-boundingBox(1,2)).^2+(boundingBox(2,1)-boundingBox(2,2)).^2));
    lengthHorz2=sqrt(((boundingBox(1,3)-boundingBox(1,4)).^2+(boundingBox(2,3)-boundingBox(2,4)).^2));
    if abs(lengthHorz1-lengthHorz2)>0.3*lengthHorz1
        %disp('horz length');
        continue;
    end
    lengthVert1=sqrt(((boundingBox(1,1)-boundingBox(1,4)).^2+(boundingBox(2,1)-boundingBox(2,4)).^2));
    lengthVert2=sqrt(((boundingBox(1,2)-boundingBox(1,3)).^2+(boundingBox(2,2)-boundingBox(2,3)).^2));
    if abs(lengthVert1-lengthVert2)>0.3*lengthVert1
        %disp('vert length');
        continue;
    end
    
    %calculate aspectratio
    %aspectRatio A4paper 1/sqrt(2)=0.707 querformat 1.414
    aspectRatio=(max(lengthHorz1,lengthHorz2)/min(lengthVert1,lengthVert2) + ...
        min(lengthHorz1,lengthHorz2)/max(lengthVert1,lengthVert2))/2;
    a4AR = 1/sqrt(2);
    
    if (aspectRatio < a4AR-0.25 || aspectRatio > a4AR+0.25) && ...
        (aspectRatio < 1/a4AR-0.25 || aspectRatio > 1/a4AR+0.25)
        %disp('aspectRatio');
        continue;
    end
    
    % angle computation
    vectors = circshift(boundingBox, -1, 2) - boundingBox;
    vectors = vectors./repmat(sqrt(vectors(1,:).^2+vectors(2,:).^2),2,1);
    
    angles = sum(vectors .* -circshift(vectors, 1, 2), 1);
    
    if any(angles < -0.44) || any(angles > 0.44) 
        continue;
    end
    
    
    if area > maxArea && area < areaLimit
        maxArea = area;
        bestBoundingBox = boundingBox;
    end
end

%Save area and angle


% plot the lines.
%plotBB(image,bestBoundingBox,linesHorizontal,linesVertical);

end

function [] =plotOriginalLines(image,lines)
    figure; 
    imshow(image);
    hold on;
    for i = 1:size(lines, 2)
        plot(lines(1:2, i), lines(3:4, i), 'LineWidth', lines(5, i) / 2, 'Color', [1, 0, 0]);
    end
    hold off;
end

function [] = plotReducedLines(image,linesHorizontal,linesVertical)
    figure;
        imshow(image);
    hold on;
    for i = 1:size(linesHorizontal, 2)
        plot(linesHorizontal(1:2, i), linesHorizontal(3:4, i), 'LineWidth', linesHorizontal(5, i) / 2, 'Color', [1, 0, 0]);
    end
    for i = 1:size(linesVertical, 2)
        plot(linesVertical(1:2, i), linesVertical(3:4, i), 'LineWidth', linesVertical(5, i) / 2, 'Color', [1, 0, 0]);
    end
    hold off;
end

function [] = plotBB(image,bestBoundingBox,linesHorizontal,linesVertical)
    figure;
    imshow(image);
    hold on; 
    for i = 1:size(linesHorizontal, 2)
        plot(linesHorizontal(1:2, i), linesHorizontal(3:4, i), 'LineWidth', linesHorizontal(5, i) / 2, 'Color', [1, 0, 0]);
    end
    for i = 1:size(linesVertical, 2)
        plot(linesVertical(1:2, i), linesVertical(3:4, i), 'LineWidth', linesVertical(5, i) / 2, 'Color', [1, 0, 0]);
    end
    plot(bestBoundingBox(1,:), bestBoundingBox(2,:), 'LineWidth', 3, 'Color', [0, 0, 1]);
    hold off;
end

function [] = plotBBs(image,boundingBoxes)
    figure;
    imshow(image);
    hold on; 
    for i=1:size(boundingBoxes,3)
        plot(boundingBoxes(1,:,i), boundingBoxes(2,:,i), 'LineWidth', 3, 'Color', [0, 0, 1]);
    end
    hold off;
end