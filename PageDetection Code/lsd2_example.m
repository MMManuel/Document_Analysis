tic
%% show the image.
im = imread('./images/ima.jpg');
imshow(im);
%% show the binary image after the process of LSD.
% note: input parameter is the path of image, use '/' as file separator.
figure;
imshow(lsd2('./images/ima.jpg'));
toc