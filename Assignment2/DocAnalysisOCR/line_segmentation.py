# in this files the lines are segmented with a horizontal projection
import cv2
from matplotlib import pyplot as plt

import numpy as np
import statistics

def get_lines(img, heightPercentageThreshold):
    projected = np.sum(img, 1);

    # debug plot of the histogram
    # plt.plot(projected); plt.show()
    lineThreshold = 0

    lines = [] # y coordinates of each line
    heights = [] # height of each line

    inLine = False
    curHeight = 0

    for i in range(0, projected.size):
        if inLine:
            if projected[i] > lineThreshold:
                curHeight = curHeight+1
            else:
                inLine = False
                heights.append(curHeight)
                curHeight = 0
        else:
            if projected[i] > lineThreshold:
                inLine = True
                curHeight = curHeight+1
                lines.append(i)

    heightThreshold = statistics.median(heights) * heightPercentageThreshold

    retLines = []
    retHeights = []
    for l in range(0, len(lines)):
        if heights[l] < heightThreshold:
            continue
        retLines.append(lines[l])
        retHeights.append(heights[l])

    return retLines, retHeights