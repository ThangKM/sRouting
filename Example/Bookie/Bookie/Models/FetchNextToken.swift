//
//  FetchNextToken.swift
//  Bookie
//
//  Created by Thang Kieu on 24/1/25.
//

import SwiftUI
import SwiftData
import ModelSendable

extension FetchDescriptor {
    
    func next(previousItemCount count: Int) -> FetchDescriptor<T>? {
        guard let offset = fetchOffset, fetchLimit != nil
        else { return nil }
        var nextToken = self
        nextToken.fetchOffset = offset + count
        return nextToken
    }
}

struct FetchNextToken<T>: Sendable where T: PersistentModel {
    
    let identifier: String
    let descriptor: FetchDescriptor<T>
    
    init?(identifier: String, descriptor: FetchDescriptor<T>?) {
        guard let descriptor else { return nil }
        self.identifier = identifier
        self.descriptor = descriptor
    }
    
    init(identifier: String, descriptor: FetchDescriptor<T>) {
        self.identifier = identifier
        self.descriptor = descriptor
    }
    
    func validate(for identifier: String) -> FetchNextToken<T>? {
        guard self.identifier == identifier else { return nil }
        return self
    }
}

struct FetchResult<T>: Sendable where T: ModelSendableType, T: PersistentModel {
    let models: [T.SendableType]
    let nextToken: FetchNextToken<T>?
    
    init(models: [T.SendableType] = [], nextToken: FetchNextToken<T>? = .none) {
        self.models = models
        self.nextToken = nextToken
    }
}
