from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import warnings

with warnings.catch_warnings():
    import sys
    import os
    import cv2
    from argparse import ArgumentParser
    import hashlib
    import numpy as np


def build_parser():
    parser = ArgumentParser()
    parser.add_argument('--main_bundle_path', type=str, dest='main_bundle_path',  required=True)
    parser.add_argument('--ignore_folder', type=str, dest='ignore_folder', default='AppIcon.appiconset,')
    parser.add_argument('--ignore_min_file_size', type=int, dest='ignore_min_file_size', default=5000)
    return parser


def search_image_assets(data_folder, ignore_folder):
    image_sets = []
    image_assets = []
    
    for root, _, file_paths in os.walk(data_folder):
        _, last_folder_name = os.path.split(root)
        if last_folder_name in ignore_folder:
            continue
        elif last_folder_name.endswith('.imageset'):
            image_sets.append(root)
        
            for file_path in file_paths:
                _, file_ext = os.path.splitext(file_path)
                if file_ext.lower() in ['.jpg', '.png']:
                    image_assets.append(os.path.join(root, file_path))

    return image_sets, image_assets


def check_duplicate_image_set_names(image_sets):
    image_set_name_dict = {}

    for image_set in image_sets:
        _, file_name = os.path.split(image_set)
        file_name, _ = os.path.splitext(file_name)

        if file_name in image_set_name_dict:
            image_set_name_dict[file_name].append(image_set)
        else:
            image_set_name_dict[file_name] = [image_set]

    def filter_duplicate_names(image_sets):
        if len(image_sets) > 1:
            print('\033[1;31mThe following images have duplicate names:\033[0m')
            for image_set in image_sets:
                print(image_set)
            return False
        return True
    
    return len(list(filter(filter_duplicate_names, image_set_name_dict.values()))) != len(image_set_name_dict)


def check_duplicate_images(image_assets, ignore_min_file_size):
    image_hash_dict = {}

    for image_asset in image_assets:
        file_size = os.path.getsize(image_asset)
        if file_size <= ignore_min_file_size:
            continue

        image = cv2.imread(image_asset)
        if image is None or np.sum(image) == 0:
            continue

        md5 = hashlib.md5()
        md5.update(image)
        image_hash = md5.hexdigest().upper()

        if image_hash in image_hash_dict:
            image_hash_dict[image_hash].append(image_asset)
        else:
            image_hash_dict[image_hash] = [image_asset]

    def filter_duplicate_images(image_assets):
        if len(image_assets) > 1:
            print('\033[1;31mThe following images have duplicate:\033[0m')
            for image_asset in image_assets:
                print(image_asset)
            return False
        return True
    
    return len(list(filter(filter_duplicate_images, image_hash_dict.values()))) != len(image_hash_dict)


def main():
    parser = build_parser()
    options = parser.parse_args()

    main_bundle_path = options.main_bundle_path
    ignore_folder = options.ignore_folder
    ignore_min_file_size = options.ignore_min_file_size

    ignore_folder = ignore_folder.strip(',').split(',')

    image_sets, image_assets = search_image_assets(main_bundle_path, ignore_folder)

    have_duplicate_names = check_duplicate_image_set_names(image_sets)
    have_duplicate = check_duplicate_images(image_assets, ignore_min_file_size)

    if have_duplicate_names or have_duplicate:
        sys.exit(-1)
    else:
        sys.exit(0)


if __name__ == '__main__':
    main()