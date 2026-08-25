//
//  RoutePickerView.swift
//  Marconio
//
//  Created by Brian Michel on 2/3/22.
//

import Foundation
import AVKit
import SwiftUI

#if canImport(AppKit)
import AppKit

public struct RoutePickerView: NSViewRepresentable, Equatable {
    public var routePickerButtonBordered: Bool = true
    public var player: AVPlayer
    public var buttonTintColor: Color?

    public typealias NSViewType = AVRoutePickerView

    public init(
        routePickerButtonBordered: Bool = true,
        player: AVPlayer,
        buttonTintColor: Color? = nil
    ) {
        self.routePickerButtonBordered = routePickerButtonBordered
        self.player = player
        self.buttonTintColor = buttonTintColor
    }

    public func makeNSView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.player = player
        view.isRoutePickerButtonBordered = routePickerButtonBordered
        view.setAccessibilityLabel("AirPlay")
        applyTint(to: view)

        return view
    }

    public func updateNSView(_ nsView: AVRoutePickerView, context: Context) {
        // PlaybackClient replaces its AVPlayer when the selected stream
        // changes, so the native picker must follow the current instance.
        nsView.player = player
        nsView.isRoutePickerButtonBordered = routePickerButtonBordered
        applyTint(to: nsView)
    }

    public func buttonTint(_ color: Color) -> Self {
        var copy = self
        copy.buttonTintColor = color
        return copy
    }

    private func applyTint(to view: AVRoutePickerView) {
        guard let buttonTintColor else { return }
        let color = NSColor(buttonTintColor)
        view.setRoutePickerButtonColor(color, for: .normal)
        view.setRoutePickerButtonColor(color, for: .normalHighlighted)
        view.setRoutePickerButtonColor(color, for: .active)
        view.setRoutePickerButtonColor(color, for: .activeHighlighted)
    }
}
#endif

#if canImport(UIKit)
import UIKit

public struct RoutePickerView: UIViewRepresentable, Equatable {
    public var player: AVPlayer
    public var buttonTintColor: Color?
    public func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.accessibilityLabel = "AirPlay"
        applyTint(to: view)
        return view
    }

    public init(player: AVPlayer, buttonTintColor: Color? = nil) {
        self.player = player
        self.buttonTintColor = buttonTintColor
    }

    public func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        applyTint(to: uiView)
    }

    public func buttonTint(_ color: Color) -> Self {
        var copy = self
        copy.buttonTintColor = color
        return copy
    }

    private func applyTint(to view: AVRoutePickerView) {
        guard let buttonTintColor else { return }
        let color = UIColor(buttonTintColor)
        view.tintColor = color
        view.activeTintColor = color
    }

    public typealias UIViewType = AVRoutePickerView
}
#endif
