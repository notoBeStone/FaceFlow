//
//  File.swift
//  Adjust
//
//  Created by user on 2024/9/26.
//

import Foundation
import GRDB
import AppModels
import GLMP

// 数据库里的Entity

//public struct MyFolderPlantsEntity: GLMPDBLiveDataEntity, FetchableRecord {
//    
//    public typealias Model = MyFolderWithMyPlantListAppModel
//    
//    var folder: MyFolderEntity     // The base record
//    var myPlants: [MyPlantDAO.MergedData] // The required associated record
//    
//    init(folder: MyFolderEntity, myPlants: [MyPlantDAO.MergedData]) {
//        self.folder = folder
//        self.myPlants = myPlants
//    }
//
//    public static func toModel(entity: MyFolderPlantsEntity) -> MyFolderWithMyPlantListAppModel? {
//        guard let folderModel = MyFolderEntity.toModel(entity: entity.folder) else { return nil }
//        let plants = entity.myPlants.compactMap { MyPlantEntity.toModel(entity: $0.toEntity()) }
//        let model = MyFolderWithMyPlantListAppModel(folder: folderModel, plants: plants)
//        return model
//    }
//}
//
//extension MyFolderWithMyPlantListAppModel: GLMPDBLiveDataModel {
//    
//    public typealias Entity = MyFolderPlantsEntity
//    
//    public static func toEntity(model: MyFolderWithMyPlantListAppModel) -> MyFolderPlantsEntity {
//        let folderEntity = MyFolderAppModel.toEntity(model: model.folder)
//        let myPlantEntities = model.plants.compactMap { model in
//            MyPlantDAO.MergedData(myPlant: MyPlantAppModel.toEntity(model: model), plant: PlantAppModel.toEntity(model: model.plant))
//        }
//        return MyFolderPlantsEntity(folder: folderEntity, myPlants: myPlantEntities)
//    }
//}
