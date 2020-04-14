import os
import codecs
import chardet

# 转换文件格式和编码方式
def to_lf(path, encoding = 'utf-8'):

    with open(path, 'rb') as infile:
        str = infile.read()
        codeType = chardet.detect(str)['encoding']
        with open(path, newline = None, encoding = codeType) as infile2:
            str2 = infile2.readlines()
            with open(path, 'w', newline= '\n', encoding = encoding) as outfile:
                outfile.writelines(str2)
                print("文件转换成功，原编码：{0}，编码：{1} ;路径：{2}".format(codeType, encoding, path))
        
        
def change_encode(dirName):
    rootPath = os.path.join(os.getcwd(), dirName)
    for dir, dirs, files in os.walk(rootPath):
        for fs in files:
            if fs.find(".yml") >= 0 or fs.find(".lang") >= 0 or fs.find(".csv") >= 0 :
                path = os.path.join(dir, fs)
                to_lf(path)

if __name__ == "__main__":
    for dir in os.listdir(os.getcwd()):
        if os.path.isdir(dir) and dir != 'zips' and dir != '.git' :
            change_encode(dir)
