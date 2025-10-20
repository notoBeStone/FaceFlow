//
//  NoteGenerateStatge.swift
//  AppModels
//
//  Created by Martin on 2024/11/15.
//

import Foundation

public enum NoteGenerateStatge {
    // 上传资源
    case resourceUploading
    // 生成Note
    case generating
    // 上传资源失败
    case uploadAudioFailed
    // 生成Note失败
    case generateNoteFailed
}
