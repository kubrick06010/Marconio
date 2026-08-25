//
//  AppCoreTests.swift
//  
//
//  Created by Brian Michel on 2/8/22.
//

@testable import AppCore
import ComposableArchitecture
import AppDelegate
import LaceKit
import XCTest

class AppCoreTests: XCTestCase {
    @MainActor
    func testIntegration() async {
        let state = AppReducer.State(channels: [],
                             mixtapes: [],
                             playback: .init(),
                             appDelegate: .init())
        let mainQueue = DispatchQueue.test

        let store = TestStore(initialState: state,
                              reducer: { AppReducer(api: NoopAPI()) }) {
            $0.dbClient = .noop
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }

        await store.send(AppReducer.Action.loadInitialData)
        await store.receive(AppReducer.Action.channelsResponse(.success(.init(results: [], links: []))))
        await store.receive(AppReducer.Action.mixtapesResponse(.success(.init(results: [], links: []))))
        await store.send(.loadChannels)
        await store.receive(.channelsResponse(.success(.init(results: [], links: []))))
        await store.send(.loadMixtapes)
        await store.receive(.mixtapesResponse(.success(.init(results: [], links: []))))
        await store.skipInFlightEffects()
    }
}
