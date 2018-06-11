from ocr import ocr_per_image
from levenshtein import levenshtein
import numpy as np

import os
foldername = '../I AM printed/'
all = []
for file in os.listdir(foldername):
    filename, file_extension = os.path.splitext(file)
    if (file_extension == '.png'):
        try:
            gt, prediction = ocr_per_image(foldername + filename)
            distance = levenshtein(gt, prediction)
            relDistance = distance / len(gt)
            all.append(relDistance)
            print(str(filename) + ": "  + str(distance) + "/" + str(len(gt)) + "=" + str(round(relDistance,2)))
        except IndexError:
            print(str(filename) + ": Invalid Segmentation -> skipping")
avg = np.average(np.array(relDistance))
print('Average '+str(round(avg,2)))