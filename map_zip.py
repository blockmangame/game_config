import os, zipfile
import argparse

# 转换文件格式和编码方式
def to_lf(path, isLF, encoding = 'utf-8'):
    """
    :param path: 文件路径
    :param isLF: True 转为Unix(LF)  False 转为Windows(CRLF)
    :param encoding: 编码方式，默认utf-8
    :return:
    """
    newline = '\n' if isLF else '\r\n'
    tp = 'Unix(LF)' if isLF else 'Windows(CRLF)'
    with open(path, newline=None, encoding='utf-8-sig') as infile:
        str = infile.readlines()
        with open(path, 'w', newline=newline, encoding=encoding) as outfile:
            outfile.writelines(str)
            print("文件转换成功，格式：{0} ;编码：{1} ;路径：{2}".format(tp, encoding, path))

def change_encode(dirName):
    rootPath = os.path.join(os.getcwd(), dirName)
    isLF = True  # True 转为Unix(LF)  False 转为Windows(CRLF)
    for dir, dirs, files in os.walk(rootPath):
        for fs in files:
            if fs.find(".yml") >= 0 or fs.find(".lang") >= 0 :
                path = os.path.join(dir, fs)
                to_lf(path, isLF)

def zip_dir(dirName):
    rootPath = os.path.join(os.getcwd(), dirName)
    outputName = './zips/' + dirName + '.zip'
    zip = zipfile.ZipFile(outputName, 'w', zipfile.ZIP_DEFLATED)
    pre_len = len(rootPath)
    for dir, dirs, files in os.walk(rootPath):
        for fs in files:
            path = os.path.join(dir, fs)
            arcname = path[pre_len:].strip(os.path.sep)
            if dir == rootPath :
                if fs.find(".iml") < 0 :
                    zip.write(path, arcname)
            else :
                if fs.find(".bat") < 0 :
                    zip.write(path, arcname)
    zip.close()

def parse_args():
    parser = argparse.ArgumentParser(description=u'自动打包游戏地图脚本')
    parser.add_argument('-d', '--dir', required=True, help=u'需要打包游戏地图文件夹')
    return parser.parse_args()

if __name__ == "__main__":
    zipPath = os.path.join(os.getcwd(), 'zips')
    if not os.path.exists(zipPath):
        os.makedirs(zipPath)
    #dir = parse_args().dir
    
    for dir in os.listdir(os.getcwd()):
        if os.path.isdir(dir) and dir != 'zips' and dir != '.git' :
            change_encode(dir)
            zip_dir(dir)
        
    #change_encode(dir)
    #zip_dir(dir)