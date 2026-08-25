//
//  AppCoreTests.swift
//  
//
//  Created by Brian Michel on 2/8/22.
//

@testable import AppCore
import ComposableArchitecture
import AppDelegate
import AppTileClient
import DatabaseClient
import LaceKit
import Models
import PlaybackCore
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

    @MainActor
    func testRefreshesMetadataForTunedChannelWithoutReloadingPlayback() async {
        let initialChannel = channel(title: "Old Show")
        let updatedChannel = channel(title: "New Show")
        let initialPlayable = MediaPlayable(channel: initialChannel)
        let updatedPlayable = MediaPlayable(channel: updatedChannel)

        let store = TestStore(
            initialState: AppReducer.State(
                channels: [initialChannel],
                playback: .init(currentlyPlaying: initialPlayable, playerState: .playing)
            ),
            reducer: { AppReducer(api: NoopAPI()) }
        ) {
            $0.appTileClient = .noop
            $0.dbClient = .noop
        }

        await store.send(
            .db(.realTimeUpdate(.success(.init(channels: [updatedChannel], mixtapes: []))))
        ) {
            $0.channels = [updatedChannel]
        }
        await store.receive(.playback(.refreshMetadata(updatedPlayable))) {
            $0.playback.currentlyPlaying = updatedPlayable
        }
        await store.receive(.playback(.updateNowPlaying))
    }

    private func channel(title: String) -> Channel {
        let now = Broadcast(
            broadcastTitle: title,
            startTimestamp: Date(),
            endTimestamp: Date().addingTimeInterval(3_600),
            links: [],
            embeds: [:]
        )
        let next = Broadcast(
            broadcastTitle: "Next Show",
            startTimestamp: Date().addingTimeInterval(3_600),
            endTimestamp: Date().addingTimeInterval(7_200),
            links: [],
            embeds: [:]
        )
        return Channel(channelName: "1", now: now, next: next)
    }
}
