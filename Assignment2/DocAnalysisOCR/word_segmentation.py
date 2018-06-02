# in this files the words are segmented with a vertical projection
import cv2
from matplotlib import pyplot as plt

import numpy as np

def get_words(img, lines, heights):

    words = [] # x coordinates of each word
    widths = [] # width of each word

    for l in range(0, len(lines)):

        words.append([])
        widths.append([])

        line = img[range(lines[l], lines[l] + heights[l])]
        line = cv2.dilate(line, np.ones((5,5), np.uint8)) # delate line further to only recognize whole words, no single characters
        projected = np.sum(line, 0);

        #cv2.imshow("image", line)
        #cv2.waitKey(0)
        #cv2.destroyAllWindows()

        # debug plot of the histogram
        #plt.plot(projected); plt.show()
        wordThreshold = 0

        inWord = False
        curWidth = 0

        for i in range(0, projected.size):
            if inWord:
                if projected[i] > wordThreshold:
                    curWidth = curWidth+1
                else:
                    inWord = False
                    widths[l].append(curWidth)
                    curWidth = 0
            else:
                if projected[i] > wordThreshold:
                    inWord = True
                    words[l].append(i)

    return words, widths
