from __future__ import print_function
import keras
import cv2
import numpy as np
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import backend as K
import genLetters as gl

batch_size = 128
num_classes = len(gl.possibleChars)
epochs = 12
img_rows, img_cols = 28, 28 # input image dimensions

# loads the labels and images from the specified tsv file
def loadDataset(filename):
    print("Loading dataset "+filename)
    images, labels, indizes = [], [], []
    with open(filename) as tsvfile:
        for index, line in enumerate(tsvfile):
            image, label, index = line.strip().split()
            img = cv2.imread(image)
            img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            images.append(img)
            labels.append(label)
            indizes.append(index)
    numberImages = len(images)
    x = np.zeros((numberImages, img_rows, img_cols))
    y = np.zeros((numberImages))
    for i in range(numberImages):
        x[i] = images[i]
        y[i] = indizes[i]
    return x, y


x_train, y_train = loadDataset('Train.tsv')
x_test, y_test = loadDataset('Test.tsv')

if K.image_data_format() == 'channels_first':
    x_train = x_train.reshape(x_train.shape[0], 1, img_rows, img_cols)
    x_test = x_test.reshape(x_test.shape[0], 1, img_rows, img_cols)
    input_shape = (1, img_rows, img_cols)
else:
    x_train = x_train.reshape(x_train.shape[0], img_rows, img_cols, 1)
    x_test = x_test.reshape(x_test.shape[0], img_rows, img_cols, 1)
    input_shape = (img_rows, img_cols, 1)

x_train = x_train.astype('float32')
x_test = x_test.astype('float32')
x_train /= 255
x_test /= 255
print('x_train shape:', x_train.shape)
print(x_train.shape[0], 'train samples')
print(x_test.shape[0], 'test samples')

# convert class vectors to binary class matrices
y_train = keras.utils.to_categorical(y_train, num_classes)
y_test = keras.utils.to_categorical(y_test, num_classes)

model = Sequential()
model.add(Conv2D(32, kernel_size=(3, 3),
                 activation='relu',
                 input_shape=input_shape))
model.add(Conv2D(64, (3, 3), activation='relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.25))
model.add(Flatten())
model.add(Dense(128, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(num_classes, activation='softmax'))

# model.summary()

model.compile(loss=keras.losses.categorical_crossentropy,
              optimizer=keras.optimizers.Adadelta(),
              metrics=['accuracy'])

model.fit(x_train, y_train,
          batch_size=batch_size,
          epochs=epochs,
          verbose=1,
          validation_data=(x_test, y_test))
score = model.evaluate(x_test, y_test, verbose=0)
print('Test loss:', score[0])
print('Test accuracy:', score[1])

print('Saving model and weights')
model.save('ocrCNNmodel.h5')