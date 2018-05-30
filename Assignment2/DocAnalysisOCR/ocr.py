import cv2

def ocr_per_image(img_url):

    orig_image = cv2.imread(img_url, 0)
    cv2.imshow("image", orig_image)
    cv2.waitKey(0)
    cv2.destroyAllWindows()