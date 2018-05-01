%% Load videframes
ImagePath='./images/myImage.jpg';
v = VideoReader('./video/magazine003.avi');
vImage=read(v,50);

%vImage = rgb2gray(vImage);
%level = graythresh(vImage);
%vImage = imbinarize(vImage,level);

imwrite(vImage,ImagePath);

%% Show Image
image = imread(ImagePath);

%% get the start_points and end_points of each straight line use LSD.
lines = lsd(ImagePath);




% labImage = rgb2lab(image);
% lImage = uint8(labImage(:,:,1));
% hisImage=histeq(lImage);
% grayImage=rgb2gray(image);


%% discard lines

img_width=size(image,2);
img_height=size(image,1);
length=(lines(1,:)-lines(2,:)).^2+(lines(3,:)-lines(4,:)).^2;
indices=find(length>0 & ...                                              %length removal
    lines(1,:)<img_width*0.8 & lines(1,:)>img_width*0.2 & ...      %surrounding x1 removal
    lines(2,:)<img_width*0.8 & lines(2,:)>img_width*0.2 & ...      %surrounding x2 removal
    lines(3,:)<img_height*0.9 & lines(3,:)>img_height*0.1 & ...    %surrounding y1 removal
    lines(4,:)<img_height*0.9 & lines(4,:)>img_height*0.1);        %surrounding y2 removal
lines=lines(:,indices);
indicesVertical=find(abs(lines(1,:)-lines(2,:))./abs(lines(3,:)-lines(4,:))<1);
indicesHorizontal=find(abs(lines(1,:)-lines(2,:))./abs(lines(3,:)-lines(4,:))>1);
linesVertical=lines(:,indicesVertical);
linesHorizontal=lines(:,indicesHorizontal);

%% join lines
%liHorX = linesHorizontal(1:2, :);
%liHorY = linesHorizontal(3:4, :);
%liHorX(3,:) = NaN;
%liHorY(3,:) = NaN;

%[x, y] = polymerge(liHorX(:), liHorY(:), 10);

margin = 10;

numLines = size(linesHorizontal,2);

for hLines=1:size(linesHorizontal,2)
    found = 1;
    
    foundLines = [linesHorizontal(:, hLines)];
    prevEqual = false(1,65);
    prevEqual(hLines) = 1;
    
    
    while found <= size(foundLines,2)
       x1_1Equal = repmat(foundLines(1, found) - margin, 1, numLines)  <= linesHorizontal(1, :) ...
                & repmat(foundLines(1, found) + margin, 1, numLines)  >= linesHorizontal(1, :);
       x1_2Equal = repmat(foundLines(1, found) - margin, 1, numLines)  <= linesHorizontal(2, :) ...
                & repmat(foundLines(1, found) + margin, 1, numLines)  >= linesHorizontal(2, :);
       x2_1Equal = repmat(foundLines(2, found) - margin, 1, numLines)  <= linesHorizontal(1, :) ...
                & repmat(foundLines(2, found) + margin, 1, numLines)  >= linesHorizontal(1, :);
       x2_2Equal = repmat(foundLines(2, found) - margin, 1, numLines)  <= linesHorizontal(2, :) ...
                & repmat(foundLines(2, found) + margin, 1, numLines)  >= linesHorizontal(2, :);
            
       y1_1Equal = repmat(foundLines(3, found) - margin, 1, numLines)  <= linesHorizontal(3, :) ...
                & repmat(foundLines(3, found) + margin, 1, numLines)  >= linesHorizontal(3, :);
       y1_2Equal = repmat(foundLines(3, found) - margin, 1, numLines)  <= linesHorizontal(4, :) ...
                & repmat(foundLines(3, found) + margin, 1, numLines)  >= linesHorizontal(4, :);
       y2_1Equal = repmat(foundLines(4, found) - margin, 1, numLines)  <= linesHorizontal(3, :) ...
                & repmat(foundLines(4, found) + margin, 1, numLines)  >= linesHorizontal(3, :);
       y2_2Equal = repmat(foundLines(4, found) - margin, 1, numLines)  <= linesHorizontal(4, :) ...
                & repmat(foundLines(4, found) + margin, 1, numLines)  >= linesHorizontal(4, :);
            
       equal = x1_1Equal & y1_1Equal | x1_2Equal & y1_2Equal ...
           | x2_1Equal & y2_1Equal | x2_2Equal & y2_2Equal;

        found = found + 1;
        
        foundLines = [foundLines, linesHorizontal(:, equal & ~prevEqual)];
        
        prevEqual = prevEqual | equal;
    end
    
    % sets all found to zero so they are not found again
    linesHorizontal(:, prevEqual) = zeros(size(linesHorizontal,1), sum(prevEqual));
    linesHorizontal(:, hLines) =  [min(min(foundLines(1,:)),min(foundLines(2,:))) max(max(foundLines(1,:)),max(foundLines(2,:)))...
         min(min(foundLines(3,:)),min(foundLines(4,:))) max(max(foundLines(3,:)),max(foundLines(4,:))), max(foundLines(5,:))];
    
end

linesHorizontal = linesHorizontal(:, linesHorizontal(5,:) ~= 0);


%% compute bounding boxes

%boundingBoxes = [];
i = 0;
for hLines1=1:size(linesHorizontal,2)
    for hLines2=hLines1+1:size(linesHorizontal,2)
        for vLines1=1:size(linesVertical,2)
            for vLines2=vLines1+1:size(linesVertical,2)
                i = i+1;
                %boundingBoxes(i, :, :) = calcBoundingBox(linesHorizontal(1:4,hLines1),linesHorizontal(1:4,hLines2),linesVertical(1:4,vLines1),linesVertical(1:4,vLines2));
            end
        end
    end
end

% choose best quad
maxArea = 0;
bestBoundingBox = [];


for i = 1:size(boundingBoxes,1)
    % reorder corner points
    boundingBox = reshape(boundingBoxes(i, :, :), [2 4]);
    [order,area]=convhull(boundingBox(1,:),boundingBox(2,:));
    %boundingBox points in counterclockwise order
    boundingBox=horzcat(boundingBox(:,order(1)),boundingBox(:,order(2)),boundingBox(:,order(3)),boundingBox(:,order(4)));
    
    
    %check if horizontal lines have equal length also vertical lines
    lengthHorz1=sqrt(((boundingBox(1,1)-boundingBox(1,2)).^2+(boundingBox(2,1)-boundingBox(2,2)).^2));
    lengthHorz2=sqrt(((boundingBox(1,3)-boundingBox(1,4)).^2+(boundingBox(2,3)-boundingBox(2,4)).^2));
    if abs(lengthHorz1-lengthHorz2)>0.2*lengthHorz1
        continue;
    end
    lengthVert1=sqrt(((boundingBox(1,1)-boundingBox(1,4)).^2+(boundingBox(2,1)-boundingBox(2,4)).^2));
    lengthVert2=sqrt(((boundingBox(1,2)-boundingBox(1,3)).^2+(boundingBox(2,2)-boundingBox(2,3)).^2));
    if abs(lengthVert1-lengthVert2)>0.2*lengthVert1
        continue;
    end
    
    %calculate aspectratio
    %aspectRatio A4paper 1/sqrt(2)=0.707 querformat 1.414
    aspectRatio=lengthHorz1/lengthVert1;
    a4AR = 1/sqrt(2);
    
    if (aspectRatio < a4AR-0.05 || aspectRatio > a4AR+0.05) && ...
        (aspectRatio < 1/a4AR-0.05 || aspectRatio > 1/a4AR+0.05)
        continue;
    end
    
    % angle computation
    vectors = circshift(boundingBox, -1, 2) - boundingBox;
    vectors = vectors./sqrt(vectors(1,:).^2+vectors(2,:).^2);
    
    angles = sum(vectors .* -circshift(vectors, 1, 2), 1);
    
    if any(angles < -0.35) || any(angles > 0.35) 
        continue;
    end
    
    
    if area > maxArea && area < 250000
        maxArea = area;
        bestBoundingBox = boundingBox;
    end
end


bestBoundingBox

 [order,area]=convhull(bestBoundingBox(1,:),bestBoundingBox(2,:));
 lengthHorz1=sqrt(((bestBoundingBox(1,1)-bestBoundingBox(1,2)).^2+(bestBoundingBox(2,1)-bestBoundingBox(2,2)).^2))
 lengthHorz2=sqrt(((bestBoundingBox(1,3)-bestBoundingBox(1,4)).^2+(bestBoundingBox(2,3)-bestBoundingBox(2,4)).^2))
 lengthVert1=sqrt(((bestBoundingBox(1,1)-bestBoundingBox(1,4)).^2+(bestBoundingBox(2,1)-bestBoundingBox(2,4)).^2))
 lengthVert2=sqrt(((bestBoundingBox(1,2)-bestBoundingBox(1,3)).^2+(bestBoundingBox(2,2)-bestBoundingBox(2,3)).^2))
 area
 aspectRatio=lengthHorz1/lengthVert1

vectors = circshift(bestBoundingBox, -1, 2) - bestBoundingBox;
vectors = vectors./sqrt(vectors(1,:).^2+vectors(2,:).^2);
    
angles = sum(vectors .* -circshift(vectors, 1, 2), 1)


imshow(image);
%% plot the lines.
hold on;
for i = 1:size(lines, 2)
    %plot(lines(1:2, i), lines(3:4, i), 'LineWidth', lines(5, i) / 2, 'Color', [1, 0, 0]);
end

for i = 1:size(linesHorizontal, 2)
    plot(linesHorizontal(1:2, i), linesHorizontal(3:4, i), 'LineWidth', linesHorizontal(5, i) / 2, 'Color', [1, 0, 0]);
end


    plot(bestBoundingBox(1,:), bestBoundingBox(2,:), 'LineWidth', 3, 'Color', [0, 0, 1]);