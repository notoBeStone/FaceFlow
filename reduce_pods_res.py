# -*- coding: utf-8 -*-
import os
import sys
import shutil
import hashlib
import json


def get_md5(file_path):
    with open(file_path, 'rb') as f:
        md5obj = hashlib.md5()
        md5obj.update(f.read())
        md5 = md5obj.hexdigest()
    return md5


# 判断classes_dir下代码是否使用正确的图片格式
# e.g. [UIImage imageNamed:@"25410_icon3" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
def check_image_name(classes_dir, image_name):
    oc_image_key = f'@"{image_name}"'
    swift_image_key = f'"{image_name}"'
    for r, d, f in os.walk(classes_dir):
        for file in f:
            code_file = os.path.join(r, file)
            if os.stat(code_file).st_size != 0:
                overwrite = False
                file_content = ""
                with open(code_file, 'r', encoding='UTF-8') as myfile:
                    if code_file.endswith('.swift'):
                        for line in myfile.readlines():
                            if swift_image_key in line:
                                if '.imageOrMain' not in line:
                                    print(f"--- Error, {image_name} in line: {line} in file: {code_file}.\n")
                                    return False
                    else:
                        for line in myfile.readlines():
                            if oc_image_key in line:
                                if 'UIImage imageNamed' not in line:
                                    print(f"--- Error, {image_name} in line: {line} in file: {code_file}.\n")
                                    return False
                                if '[NSBundle bundleForClass:self.class]' not in line and '[NSBundle mainBundle]' not in line:
                                    print(f"--- Error, {image_name} in line: {line} in file: {code_file}.\n")
                                    return False
    print(f"--- {image_name} 使用正确，可以replace.\n")
    return True


def replace_image_name(classes_dir, image_name, new_name):
    oc_image_key = f'@"{image_name}"'
    oc_new_key = f'@"{new_name}"'
    swift_image_key = f'"{image_name}"'
    swift_new_key = f'"{new_name}"'
    for r, d, f in os.walk(classes_dir):
        for file in f:
            code_file = os.path.join(r, file)
            if os.stat(code_file).st_size != 0:
                overwrite = False
                file_content = ""
                with open(code_file, 'r', encoding='UTF-8') as myfile:
                    if code_file.endswith('.swift'):
                        for line in myfile.readlines():
                            if swift_image_key in line and '.imageOrMain' in line:
                                overwrite = True
                                line = line.replace(swift_image_key, swift_new_key)
                            file_content += line
                    else:
                        for line in myfile.readlines():
                            if oc_image_key in line and 'UIImage imageNamed' in line:
                                overwrite = True
                                line = line.replace(oc_image_key, oc_new_key)
                                if '[NSBundle bundleForClass:self.class]' in line:
                                    line = line.replace('[NSBundle bundleForClass:self.class]', '[NSBundle mainBundle]')
                            file_content += line
                if overwrite:
                    os.chmod(code_file, 0o666) # 改变文件可写
                    with open(code_file, 'w', encoding='UTF-8') as myfile:
                        myfile.write(file_content)


def main(argv):
    try:
        project_dir = argv[0] # app 根目录
        resource_folder = argv[1] # app Images.xcassets folder, e.g. DangJi/Resources/Images.xcassets
        pods_dir = os.path.join(project_dir, 'Pods')
        for dir in os.listdir(pods_dir):
            path = os.path.join(pods_dir, dir)
            if os.path.isdir(path) and os.path.basename(path).startswith('Vip'): # 找到所有转换页pod
                print(f"--- pod path: {path}.\n")
                classes_dir = os.path.join(path, 'GLPurchaseUI/Classes') # 转换页pod代码folder
                image_dir = os.path.join(path, 'GLPurchaseUI/Assets/Images.xcassets') # 转换页所有image folder
                print(f"--- image dir: {image_dir}, classes dir: {classes_dir}.\n")
                if not os.path.exists(image_dir):
                    print("--- image dir not exists.\n")
                if not os.path.exists(classes_dir):
                    print("--- classes dir not exists.\n")
                for r, d, f in os.walk(image_dir):
                    for dd in d:
                        if dd.endswith('.imageset'):  # 单个image folder，e.g. 26600_Vector.imageset
                            image_folder = os.path.join(r, dd)
                            print(f"--- image folder: {image_folder}.\n")
                            new_folder_name = None
                            files_md5 = []
                            for file in sorted(os.listdir(image_folder)):  # 获取26600_Vector.imageset folder下所有图片文件的MD5值
                                image_file = os.path.join(image_folder, file)
                                file_name = os.path.basename(image_file)
                                if os.path.isfile(image_file) and file_name != 'Contents.json':
                                    print(f"--- image file: {image_file}.\n")
                                    md5 = get_md5(image_file)
                                    files_md5.append(md5)
                            if len(files_md5) != 0: # 将所有图片文件的MD5值写入文件，把这个文件的MD5值作为26600_Vector.imageset folder的MD5值
                                md5_files = os.path.join(image_folder, 'md5_files.txt')
                                with open( md5_files, "w", encoding='UTF-8') as myfile:
                                    myfile.write('\n'.join(files_md5))
                                new_folder_name = get_md5(md5_files)
                                os.remove(md5_files)
                            image_name = os.path.basename(image_folder).replace('.imageset', '')
                            if check_image_name(classes_dir, image_name): # 检查图片是否使用正确规则来决定是否可以被替换
                                replace_image_name(classes_dir, image_name, new_folder_name) # 替换代码中使用的图片名字
                                new_image_folder = os.path.join(os.path.dirname(image_folder), new_folder_name + '.imageset')
                                os.rename(image_folder, new_image_folder)
                                new_folder_path = os.path.join(resource_folder, new_folder_name + '.imageset')
                                if not os.path.exists(new_folder_path):
                                    print(f"--- move image folder {image_folder} to {new_folder_path}.\n")
                                    shutil.move(new_image_folder,
                                                resource_folder)  # 移动26600_Vector.imageset folder到'resource_folder'下
                                if os.path.exists(new_image_folder):
                                    print(f"--- delete image folder {image_folder}.\n")
                                    shutil.rmtree(new_image_folder)  # 删除26600_Vector.imageset folder

        print(f"--- Done ---.\n")
    except Exception as exception:
        if hasattr(exception, 'message'):
            message = exception.message
        else:
            message = str(exception)
        print(f"Error, {message}\n")


if __name__ == '__main__':
    argv = sys.argv[1:]
    if len(argv) < 2:
        sys.exit()
    main(argv)
