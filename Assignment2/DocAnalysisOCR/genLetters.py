import numpy as np
from numpy.random import randint
import os
import string
import cv2
import preprocess as pp
from PIL import Image, ImageFont, ImageDraw

possibleChars = list(string.ascii_letters + string.digits + ".,")
genSize = (56, 56)
outSize = 28
fontColor = (255, 255, 255)
bgColor = 0
fontsize = 50
fonts = []
fontfolder = 'fonts/'


# loads all fonts from the fonts folder
def load_fonts():
    for file in os.listdir(fontfolder):
        if file.endswith(".ttf") or file.endswith(".otf"):
            fonts.append(ImageFont.truetype(fontfolder + file, fontsize))


# creates a rectangular image of one random letter in a random font
def draw_random_letter():
    if len(fonts)==0:
        load_fonts()
    fontindex = randint(0, len(fonts))

    index = randint(0, len(possibleChars))
    char = possibleChars[index]
    img = np.zeros((genSize[0], genSize[1], 3), np.uint8)
    img.fill(bgColor)

    img_pil = Image.fromarray(img)
    draw = ImageDraw.Draw(img_pil)
    draw.text((0, 0), char, fontColor, font=fonts[fontindex])
    img = np.array(img_pil)

    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img = pp.cropImage(img)
    img = pp.unify_image(img, outSize)
    return img, char, index


# generates multiple letters and saves them to the specified folder, and a tsv file with labels
def generate_letters(number_images=128, folder='Train'):
    print('Generating ' + str(number_images) + ' Images in folder ' + folder)
    y = []
    for i in range(number_images):  # Write images to output directory
        image, label, index = draw_random_letter()
        filename = os.path.join(folder, '{:05d}.png'.format(i))
        cv2.imwrite(filename, image)
        y.append(filename + '\t' + label + '\t' + str(index))
    with open(folder + '.tsv', 'w') as file:  # Write CSV file
        file.write('\n'.join(y))


if __name__ == "__main__":
    generate_letters(number_images=16384, folder='Train')
    generate_letters(number_images=4069, folder='Test')
