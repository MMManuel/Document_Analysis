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