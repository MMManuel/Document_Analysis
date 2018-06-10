import numpy as np
from numpy.random import randint
import os
import string
import cv2
import preprocess as pp
from PIL import Image, ImageFont, ImageDraw

xy = (0, 0)
genSize = (56, 56)
outSize = 28
fontColor = (255,255,255)
bgColor = 0
fontsize = 50
font = ImageFont.truetype('Baskerville.ttf', fontsize)
possibleChars = list(string.ascii_letters + string.digits + ".,")

def paintImage():
    char = possibleChars[randint(0, len(possibleChars))]
    img = np.zeros((genSize[0], genSize[1], 3), np.uint8)
    img.fill(bgColor)

    img_pil = Image.fromarray(img)
    draw = ImageDraw.Draw(img_pil)
    draw.text(xy, char, fontColor, font=font)
    img = np.array(img_pil)

    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img = pp.cropImage(img)
    img = pp.resizeAndPadImage(img, outSize)
    return img, char


def generateImages(numberImages=128, folder='Train'):
    Y = []
    for i in range(numberImages):  # Write images to output directory
        image, label = paintImage()
        filename = os.path.join(folder, '{:05d}.png'.format(i))
        cv2.imwrite(filename, image)
        Y.append(filename + ',' + label)
    with open(folder + '.csv', 'w') as F:  # Write CSV file
        F.write('\n'.join(Y))

if __name__ == "__main__":
    print('Generating Images')
    generateImages(numberImages=100, folder='Train')
    generateImages(numberImages=100, folder='Test')