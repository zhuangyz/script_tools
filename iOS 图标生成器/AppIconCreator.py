#!/usr/bin/env python
# coding = UTF-8
# Author:lxt

import sys
import os
import os.path
from PIL import Image
import json


# pip install Pillow


def ResizeImage(filein, fileout, width, height):
    img = Image.open(filein)
    img.thumbnail((width, height), Image.ANTIALIAS)
    img.save(fileout)


if __name__ == '__main__':
    """
    针对iOS，根据一张1024*1024的应用图标，生成各个尺寸的图标
    运行后，会在1024图标的所在目录下，创建一个 app_icons 文件夹，各个尺寸的图标将在这个文件夹下保存
    
    前提：
        环境 Python3
        安装图片处理库 Pillow：pip install Pillow
    用法：
        python3 AppIconCreator.py 1024_icon_path assets_path/AppIcon.appiconset/Contents.json
    """
    if len(sys.argv) >= 3:
        icon1024_path = sys.argv[1]
        icon_config_json_path = sys.argv[2]

        print(3 in [1, 2, 3])

        file_out_dir = icon1024_path.rpartition('/')[0]
        print(file_out_dir)
        file_out_dir = file_out_dir + "/app_icons"
        if not os.path.exists(file_out_dir):
            os.mkdir(file_out_dir)

        with open(icon_config_json_path) as fp:
            config_json = json.load(fp)

        item_infos = config_json["images"]
        sizes = []
        for item in item_infos:
            print(item)
            scale_str = item["scale"]
            size_str = item["size"]
            scale = float(scale_str.split("x")[0])
            size_conf = float(size_str.split("x")[0])
            size = int(scale * size_conf)
            if size == 1024:
                continue
            if size not in sizes:
                sizes.append(size)

        for size in sizes:
            fileout = file_out_dir + "/" + str(size) + ".png"
            ResizeImage(icon1024_path, fileout, size, size)
