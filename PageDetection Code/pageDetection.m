%% Load videframes
ImagePath='./images/myImage.jpg';
v = VideoReader('./video/magazine003.avi');
vImage=read(v,100);
imwrite(vImage,ImagePath);

%% Show Image
image = imread(ImagePath);
imshow(image);

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
indices=find(length>1000 & ...                                              %length removal
             lines(1,:)<img_width*0.8 & lines(1,:)>img_width*0.2 & ...      %surrounding x1 removal
             lines(2,:)<img_width*0.8 & lines(2,:)>img_width*0.2 & ...      %surrounding x2 removal
             lines(3,:)<img_height*0.9 & lines(3,:)>img_height*0.1 & ...    %surrounding y1 removal
             lines(4,:)<img_height*0.9 & lines(4,:)>img_height*0.1);        %surrounding y2 removal
lines=lines(:,indices);
indicesVertical=find(abs(lines(1,:)-lines(2,:))./abs(lines(3,:)-lines(4,:))<1);
indicesHorizontal=find(abs(lines(1,:)-lines(2,:))./abs(lines(3,:)-lines(4,:))>1); 
linesVertical=lines(:,indicesVertical);
linesHorizontal=lines(:,indicesHorizontal);

% for hLines1=1:size(linesHorizontal,2)
%     for hLines2=hLines1+1:size(linesHorizontal,2)
%         for vLines1=1:size(linesVertical,2)
%              for vLines2=vLines1+1:size(linesVertical,2)
%                 calcBoundingBox(linesHorizontal(1:4,hLines1),linesHorizontal(1:4,hLines2),linesVertical(1:4,vLines1),linesVertical(1:4,vLines2))
%             end
%         end
%     end
% end

%% plot the lines.
hold on;
for i = 1:size(lines, 2)
    plot(lines(1:2, i), lines(3:4, i), 'LineWidth', lines(5, i) / 2, 'Color', [1, 0, 0]);
end