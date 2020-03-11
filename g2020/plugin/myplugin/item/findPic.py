import json
import math
import os
import re
from PIL import Image

findCfg = "vector"

def filterFunc(value):
    if value - math.floor(value) > 0:
        return True
    else:
        return False

def changeImage(image, savePath):
    newHeight = math.floor(image.height / 32 + 0.5) * 32
    newWidth = math.floor(image.width / 32 + 0.5) * 32
    image_size = image.resize((newWidth, newHeight),Image.ANTIALIAS)
    image_size.save(savePath)

def mainWork(fileName):
    if re.match(r'.*.png$', fileName):
        filePath = os.path.join(root, fileName)
        img = Image.open(filePath)
        if img.width > 32 and img.width % 32 != 0:
            print(filePath)
            changeImage(img, filePath)
            return
        if img.height > 32 and img.height % 32 != 0:
            print(filePath)
            changeImage(img, filePath)

if __name__ == '__main__':
    for root, dirs, files in os.walk("./"):
        for file in files:
            # 获取文件路径
            mainWork(file)
