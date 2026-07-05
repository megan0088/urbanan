//
//  RegisterItemUseCase.swift
//  SharedCore
//

import Foundation

struct RegisterItemUseCase {
    private let cloudKitManager: CloudKitManaging
    private let qrManager: QRManaging;
    private let currentUserProvider: CurrentUserProviding
    private let imageCompressor: ImageCompressing
    
    init(cloudKitManager: CloudKitManaging, qrManager: QRManaging, currentUserProvider: CurrentUserProviding, imageCompressor: ImageCompressing) {
        self.cloudKitManager = cloudKitManager
        self.qrManager = qrManager
        self.currentUserProvider = currentUserProvider
        self.imageCompressor = imageCompressor
    }
    
    struct Input {
        var name: String
        var category: String
        var color: String
        var description: String
        var imageData: Data?
    }
    
    struct Output {
        var item: Item
        var qrCodeImageData: Data
        var itemLink: URL
    }
    
    func execute(_ input: Input) async throws -> Output {
        let now = Date()
        
        let compressedImageData = try input.imageData.map {
            try imageCompressor.compress($0, maxDimensionPixels: 1200, jpegQUality: 0.7)
        }
        
        let newItem = Item(id: UUID(), ownerID: currentUserProvider.currentUserID,
                           name: input.name, category: input.category, color: input.color, description: input.description,
                           imageData: compressedImageData, createdAt: now, updatedAt: now)
        let savedItem = try await cloudKitManager.saveItem(newItem)
        let qrData = try qrManager.generateQRCode(for: savedItem.id)
        let itemLink = qrManager.link(for: savedItem.id);
        return Output(item: savedItem, qrCodeImageData: qrData, itemLink: itemLink)
    }
}
