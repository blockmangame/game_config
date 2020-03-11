import json
import math
import os
import shutil
findCfg = "vector"
findPic = {}
addPath = "/block_texture/"
movePicSet = set([])
def filterFunc(value):
    if value - math.floor(value) > 0:
        return True
    else:
        return False
def findP(fileName):
    with open(fileName, 'r') as f:
        a = json.load(f)
    localPicSet = set([])
    if 'texture' in a:
        for data in a['texture']:
            localPicSet.add(data)

    if 'quads'in a:
        for data in a['quads']:
            if "texture" in data:
                localPicSet.add(data['texture'])

    if 'defaultTexture'in a:
        localPicSet.add(a['defaultTexture'])
    for data in localPicSet:
        if data in findPic:
            findPic[data] = findPic[data] + 1
        else:
            findPic[data] = 1
    # for data in a['entity']:
    #     fullName = data['cfg']
    #     if fullName.find("vector") != -1:
    #         y = data['pos']['y']
    #         filterResult = filterFunc(y)
    #         if filterResult:
    #             data['pos']['y'] = math.floor(data['pos']['y'])
    # with open(fileName,"w") as dump_f:
    #     json.dump(a, dump_f)
def mainWork(fileName, curPath):
    def copyPic(file):
        if not file in movePicSet:
            try:
                movePicSet.add(file)
                copyPicPath = os.path.join(curPath, file)
                print(copyPicPath)
                shutil.move(copyPicPath, '../block_texture/')
            except:
                print(file, "error may not find")
    with open(fileName, 'r') as f:
        a = json.load(f)
    localPicSet = set([])
    flag = False
    if 'texture' in a:
        for index in range(len(a['texture'])):
            data = a['texture'][index]
            if data in findPic and findPic[data] > 1:
                flag = True
                a['texture'][index] = addPath + data.split('/')[-1]
                copyPic(data.split('/')[-1])

    if 'quads'in a:
        for data in a['quads']:
            if "texture" in data:
                pic = data['texture']
                if pic in findPic and findPic[pic] > 1:
                    flag = True
                    data['texture'] = addPath + pic.split('/')[-1]
                    copyPic(pic.split('/')[-1])

    if 'defaultTexture'in a:
        pic = a['defaultTexture']
        if pic in findPic and findPic[pic] > 1:
            flag = True
            a['defaultTexture'] = addPath + pic.split('/')[-1]
            copyPic(pic.split('/')[-1])
    # for data in a['entity']:
    #     fullName = data['cfg']
    #     if fullName.find("vector") != -1:
    #         y = data['pos']['y']
    #         filterResult = filterFunc(y)
    #         if filterResult:
    #             data['pos']['y'] = math.floor(data['pos']['y'])
    if flag:
        with open(fileName,"w") as dump_f:
            json.dump(a, dump_f)
def delKongge(fileName):
    with open(fileName, 'r') as f:
        a = json.load(f)
    result = json.dumps(a, separators=(',', ':'))
    with open(fileName,"w") as dump_f:
        dump_f.write(result)
if __name__ == '__main__':
    for root, dirs, files in os.walk("./"):
        for file in files:
            # 获取文件路径
            if file == 'setting.json':
                findP(os.path.join(root, file))
    for root, dirs, files in os.walk("./"):
        for file in files:
            # 获取文件路径
            if file == 'setting.json':
                mainWork(os.path.join(root, file), root)
