# in this files the characters of the segmented words are segmented with again vertical projection
import cv2
from matplotlib import pyplot as plt

import numpy as np

def get_characters(img, lines, heights, words, wordWidths, minWidth):

    chars = [] # x coordinates of each word
    widths = [] # width of each word

    for l in range(0, len(lines)):
        chars.append([])
        widths.append([])

        line = img[range(lines[l], lines[l] + heights[l])]
        
        for w in range(0, len(words[l])):
            
            chars[l].append([])
            widths[l].append([])

            height, width = line.shape

            word = line[round(0.30 * height):round(0.95 * height),range(words[l][w], words[l][w] + wordWidths[l][w])]       
            #word = cv2.erode(word, np.ones((3, 3), np.uint8)) # erode line further to only recognize whole words, no single characters
            #wordCont, contours, hierarchy = cv2.findContours(word, cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
            #word = np.ones(word.shape, np.uint8);
            #cv2.drawContours(word, contours, -1, 255, 3)            
            #word = cv2.erode(word, np.ones((3,3), np.uint8)) # erode line further to only recognize whole words, no single characters


            projected = np.sum(word, 0);

            #cv2.imshow("image", word)
            #cv2.waitKey(0)
            #cv2.destroyAllWindows()

            # debug plot of the histogram
            #plt.plot(projected); plt.show()
            wordThreshold = 0

            inChar = False
            curWidth = 0

            for i in range(0, projected.size):
                if inChar:
                    if projected[i] > wordThreshold:
                        curWidth = curWidth+1
                    else:
                        inChar = False
                        widths[l][w].append(curWidth)
                        curWidth = 0
                else:
                    if projected[i] > wordThreshold:
                        inChar = True
                        curWidth = curWidth+1
                        chars[l][w].append(i)

            if inChar:
                inChar = False
                widths[l][w].append(curWidth)

    return chars, widths
