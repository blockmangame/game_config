import csv
import io
import sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer,encoding="utf-8")

fileName = "region.csv"

def readCsv(csvName):
    result = {}
    result["col_name"] = []
    result["col_info"] = []
    result["lua_name"] = csvName[0:len(csvName) - 4] + "_config.lua"

    csvFile = open(csvName, "r", encoding="UTF-8")
    lines = csv.reader(csvFile, delimiter='\t')
    for line in lines:
        if lines.line_num >= 4:
            break
        for value in line:
            if lines.line_num == 3:
                result["col_name"].append(value)
            else:
                result["col_info"].append(value)
    
    print(result["col_name"])
    print(result["col_info"])

    csvFile.close()
    return result

def genConfigString(col_name, col_info):
    prefix = col_name[0]
    colName = col_name[2:]
    if prefix == 'n':
        return "        data." + colName + " = tonumber(vConfig." + col_info + ") or 0 --" + col_info + "\n"
    else:
        return "        data." + colName + " = vConfig." + col_info + " or \"\" --" + col_info + "\n"

def genLuaFile(result):
    file = open(result["lua_name"], mode='w', encoding="utf-8")

    table_name = result["lua_name"][0 : len(result["lua_name"]) - 4]
    file.write("local " + table_name + " = T(Config, \"" + table_name + "\")\n")
    file.write("\n")
    file.write("local " + table_name + ".settings = {}\n")
    file.write("\n")
    file.write("function " + table_name + ":init(config)\n")
    file.write("    for _, vConfig in pairs(config) do\n")
    file.write("        local data = {}\n")

    #TODO
    for i in range(len(result["col_name"])):
        file.write(genConfigString(result["col_name"][i], result["col_info"][i]))

    file.write("        table.insert(" + table_name + ".settings, data)\n")
    file.write("    end\n")
    file.write("end\n")
    file.write("\n")
    file.write("return " + table_name + "\n")

result = readCsv(fileName) #文件名
genLuaFile(result)