//
//  SyncAsync.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 23.09.2025.
//

import Combine

public extension Publisher {
    func sinkAsync(
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void = { _ in },
        receiveValue: @escaping (Output) -> Void = { _ in }
    ) {
        var cancellable: AnyCancellable?
        
        cancellable = self
            .handleEvents(
                receiveCancel: {
                    if cancellable.notNil {
                        cancellable = nil
                    }
                }
            )
            .sink { result in
                receiveCompletion(result)
                cancellable = nil
            } receiveValue: { value in
                receiveValue(value)
            }
    }
}
