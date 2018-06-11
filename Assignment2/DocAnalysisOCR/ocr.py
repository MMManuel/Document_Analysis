import cv2


import xml.etree.ElementTree as ET
from preprocess import get_segmentation_image
from preprocess import get_recognition_image
from preprocess import resizeAndPadImage
from preprocess import cropImage

from line_segmentation import get_lines
from word_segmentation import get_words
from char_segmentation import get_characters


import numpy as np
from keras.models import load_model
import genLetters as gl

outSize = 28


print("Loading CNN model and weights")
model = load_model('ocrCNNmodel.h5')


def ocr_per_image(img_name):
    orig_image = cv2.imread(img_name+'.png', 0)
    #cv2.imshow("image", orig_image)

    height, width = orig_image.shape

    # preprocess
    inverted = cv2.bitwise_not(orig_image)

    segmentation_img = get_segmentation_image(orig_image)
    segmentation_img2 = get_recognition_image(orig_image)
    
    im_to_skel = cv2.erode(segmentation_img2, np.ones((2,2),np.uint8))
    # segmentation_img2 = cv2.erode(segmentation_img2, np.ones((2,2),np.uint8))
    #segmentation_img2 = cv2.dilate(segmentation_img2, np.ones((3,1),np.uint8))

    size = np.size(im_to_skel)
    skel = np.zeros(im_to_skel.shape,np.uint8)
    element = cv2.getStructuringElement(cv2.MORPH_CROSS,(3,3))
    done = False

    while( not done):
        eroded = cv2.erode(im_to_skel,element)
        temp = cv2.dilate(eroded,element)
        temp = cv2.subtract(im_to_skel,temp)
        skel = cv2.bitwise_or(skel,temp)
        im_to_skel = eroded.copy()

        zeros = size - cv2.countNonZero(im_to_skel)
        if zeros==size:
            done = True
            
    skel = cv2.dilate(skel, np.ones((3,3), np.uint8))
    skel = cv2.erode(skel, np.ones((3,3), np.uint8))

    # get lines
    lines, lineHeights = get_lines(segmentation_img, 0.45)

    # get words
    words, wordWidths = get_words(segmentation_img, lines, lineHeights)

    # get characters
    chars, charWidths = get_characters(segmentation_img2, lines, lineHeights, words, wordWidths, width / 130.0)

    letters = []

    # process segmented characters
    for l in range(0, len(lines)):
        line = inverted[range(lines[l], lines[l] + lineHeights[l])]

        for w in range(0, len(words[l])):

            wordStart = words[l][w]
            wordEnd =  words[l][w] + wordWidths[l][w]
            word = line[:,range(wordStart,wordEnd)]

            for c in range(0, len(chars[l][w])):
                char = word[:, chars[l][w][c] :chars[l][w][c] + charWidths[l][w][c]]
                char = cropImage(char)
                char = resizeAndPadImage(char, outSize=outSize)
                letters.append(char)

                #cv2.imshow("image", char)
                #cv2.waitKey(0)
                #cv2.destroyAllWindows()

    numberLetters = len(letters)
    x = np.zeros((numberLetters, outSize, outSize))
    for i in range(numberLetters):
        x[i] = letters[i]
    x = x.reshape(numberLetters, outSize, outSize, 1)
    prediction = model.predict(x)
    pindex = np.argmax(prediction, axis=1)
    chars = list(map(lambda x: gl.possibleChars[x], pindex))
    prediction = ''.join(chars).lower()

    gt = ''
    tree = ET.parse(img_name + '.xml')
    for child in tree.findall(".//machine-print-line"):
        gt += child.attrib['text']
    gt = gt.replace(' ','').lower()

    return gt, prediction