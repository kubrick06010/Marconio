//
//  File.swift
//  
//
//  Created by Brian Michel on 1/25/23.
//

import Dependencies
#if os(macOS)
import AppKit
#endif

public struct HapticsClient {
    public var play: () -> Void
}

public extension HapticsClient {
    static var live: Self {
        return Self(
            play: {
#if os(macOS)
                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
#else
                // iOS has no equivalent required by Marconio's band selector.
#endif
            }
        )
    }
}

extension HapticsClient: DependencyKey {
    public static var liveValue: HapticsClient = .live
}

extension DependencyValues {
    public var hapticsClient: HapticsClient {
        get { self[HapticsClient.self] }
        set { self[HapticsClient.self] = newValue }
    }
}
