# the preprocessing of the image for line, word and character segmentation
# the image is thresholded with an otsu threshold and invertet in order to apply projection profiles for the segmentation
# (1 = white, therefore the inverting)

import cv2
import numpy as np

def get_segmentation_image(img):
    # first blur the image to remove noise, then threshold and invert it and dilate it for better line segmentation
    ret_img = cv2.GaussianBlur(img, (5,5), 0)

    ret, ret_img = cv2.threshold(ret_img, 0, 255, cv2.THRESH_OTSU + cv2.THRESH_BINARY_INV)

    ret_img = cv2.dilate(ret_img, np.ones((2,2),np.uint8))

    return ret_img


def get_recognition_image(img):
    # for recognition only provide a blurred file to remove noise
    #ret_img = cv2.GaussianBlur(img, (3,3), 0)

    ret, ret_img = cv2.threshold(img, 0, 255, cv2.THRESH_OTSU + cv2.THRESH_BINARY_INV)

    return ret_img


def resizeAndPadImage(im, outSize):
    old_size = im.shape[:2] # old_size is in (height, width) format

    ratio = float(outSize)/max(old_size)
    new_size = tuple([int(x*ratio) for x in old_size])

    # new_size should be in (width, height) format
    im = cv2.resize(im, (new_size[1], new_size[0]))

    delta_w = outSize - new_size[1]
    delta_h = outSize - new_size[0]
    top, bottom = delta_h//2, delta_h-(delta_h//2)
    left, right = delta_w//2, delta_w-(delta_w//2)

    color = [0, 0, 0]
    new_im = cv2.copyMakeBorder(im, top, bottom, left, right, cv2.BORDER_CONSTANT,
        value=color)
    return new_im


def cropImage(img, thresimg=None):
    if thresimg is None:
        ret, thresimg = cv2.threshold(img, 128, 255, cv2.THRESH_BINARY)

    proj = thresimg.max(0)
    left = np.argmax(proj == 255)
    right = np.argmax(proj[::-1] == 255)

    proj = thresimg.max(1)
    top = np.argmax(proj == 255)
    bottom = np.argmax(proj[::-1] == 255)
    s = thresimg.shape

    img = img[top:s[0]-bottom, left:s[1]-right]
    return img