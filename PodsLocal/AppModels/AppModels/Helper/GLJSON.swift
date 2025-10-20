//
//  JSONHelper.swift
//  D2CDemo
//
//  Created by xie.longyan on 2023/12/18.
//

import Foundation
import DGMessageAPI
import GLNetworkingMessage
import GLNetworking

public struct GLJSON {
    /// Converts JSON data from a file path into a model.
    /// - Parameters:
    ///   - filePath: The file path URL as a string where the JSON data is located.
    ///   - type: The type of the model to which the JSON data will be decoded.
    /// - Returns: An optional model of the specified type if the decoding is successful.
    public static func toModel<T: Codable>(filePath: String, type: T.Type) -> T? {
        guard let url = URL(string: filePath), let jsonData = try? Data(contentsOf: url) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            debugPrint("Decoding error: \(error)")
            return nil
        }
    }
    
    /// Converts JSON data from a file in the app bundle into a model.
    /// - Parameters:
    ///   - fileName: The name of the JSON file in the app bundle.
    ///   - type: The type of the model to which the JSON data will be decoded.
    /// - Returns: An optional model of the specified type if the decoding is successful.
    public static func toModel<T: Codable>(fileName: String, type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        return toModel(filePath: url.absoluteString, type: type)
    }
    
    /// Converts a JSON string into a model.
    /// - Parameters:
    ///   - jsonString: The JSON string that needs to be decoded.
    ///   - type: The type of the model to which the JSON string will be decoded.
    /// - Returns: An optional model of the specified type if the decoding is successful.
    public static func toModel<T: Codable>(jsonString: String, type: T.Type) -> T? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            debugPrint("Decoding error: \(error)")
            return nil
        }
    }
    
    /// Converts a JSON string into a model conforming to APIJSONResponse using a custom decoder.
    /// - Parameters:
    ///   - jsonString: The JSON string that needs to be decoded.
    ///   - type: The type of the model to which the JSON string will be decoded.
    /// - Returns: An optional model of the specified type if the decoding is successful.
    public static func toModel<T: APIJSONResponse>(jsonString: String, type: T.Type) -> T? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try GLNetworkingResponse.decoder.decode(type, fromData: jsonData)
        } catch {
            debugPrint("Decoding error: \(error)")
            return nil
        }
    }
}


public func sleep(_ seconds: Double) async {
    let nanoseconds = UInt64(seconds * 1_000_000_000)
    try? await Task.sleep(nanoseconds: nanoseconds)
}
