//
//  RegisterItemUseCase.swift
//  SharedCore
//

import Foundation

struct RegisterItemUseCase {
    private let cloudKitManager: CloudKitManaging
    private let qrManager: QRManaging;
    private let currentUserProvider: CurrentUserProviding
    
    init(cloudKitManager: CloudKitManaging, qrManager: QRManaging, currentUserProvider: CurrentUserProviding) {
        self.cloudKitManager = cloudKitManager
        self.qrManager = qrManager
        self.currentUserProvider = currentUserProvider
    }
    
    struct Input {
        var name: String
        var category: String
        var color: String
        var description: String
    }
    
    struct Output {
        var item: Item
        var qrCodeImageData: Data
    }
    
    func execute(_ input: Input) async throws -> Output {
        let now = Date()
        let newItem = Item(id: UUID(), ownerID: currentUserProvider.currentUserID,
                           name: input.name, category: input.category, color: input.color, description: input.description,
                           createdAt: now, updatedAt: now)
        let savedItem = try await cloudKitManager.saveItem(newItem)
        let qrData = try qrManager.generateQRCode(for: savedItem.id)
        return Output(item: savedItem, qrCodeImageData: qrData)
    }
}
