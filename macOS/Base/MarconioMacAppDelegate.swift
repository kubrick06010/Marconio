//
//  MarconioMacAppDelegate.swift
//  Marconio
//
//  Created by Brian Michel on 1/30/22.
//

import Foundation
import AppKit
import Combine
import Sparkle
import SwiftUI
import ComposableArchitecture
import LaceKit
import AppCore
import AppDelegate
import AppDelegate_macOS
import Models
import PlaybackCore

/// Owns the radio window and the menu bar presence for the macOS app.
final class MarconioMacAppDelegate: NSObject, NSApplicationDelegate {
    private struct MenuBarPlaybackState: Equatable {
        let currentlyPlaying: MediaPlayable?
        let playerState: PlaybackReducer.State.PlayerState

        init(state: AppReducer.State) {
            currentlyPlaying = state.playback.currentlyPlaying
            playerState = state.playback.playerState
        }
    }

    private enum DefaultsKey {
        static let showInDock = "ShowInDock"
    }

    let store = Store(
        initialState: .init(),
        reducer: { AppReducer(api: LiveAPI()) }
    )

    private let dockMenu = NSMenu()
    private let mainWindow: RadioWindow
    private var statusItem: NSStatusItem?
    private lazy var menuBarViewStore = ViewStore(store, observe: MenuBarPlaybackState.init)
    private var cancellables = Set<AnyCancellable>()

    private let nowPlayingItem = NSMenuItem(title: "Nothing Playing", action: nil, keyEquivalent: "")
    private let sourceItem = NSMenuItem(title: "NTS", action: nil, keyEquivalent: "")
    private lazy var playPauseItem = NSMenuItem(
        title: "Play",
        action: #selector(togglePlayback),
        keyEquivalent: ""
    )

    override init() {
        mainWindow = RadioWindow(store: store)
        UserDefaults.standard.register(defaults: [DefaultsKey.showInDock: true])
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        applyActivationPolicy()
        store.send(.appDelegate(.willFinishLaunching))
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        store.send(.appDelegate(.didFinishLaunching))
        configureStatusItem()

        // HACK: Disable resizing of the split since that's our desired design.
        // NSApp.windows.first?.contentView?.disableSplitViewCollapsingIfPossible()

        // HACK: Disable the zoom button so you can't expand the app to fill the screen.
        // NSApp.windows.first?.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isEnabled = false

        openMarconio()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        openMarconio()
        return true
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        return dockMenu
    }

    func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
        store.send(.appDelegate(.continueActivity(userActivity)))
        return true
    }

    private var showsInDock: Bool {
        UserDefaults.standard.bool(forKey: DefaultsKey.showInDock)
    }

    private func configureStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(
            systemSymbolName: "radio",
            accessibilityDescription: "Marconio"
        )
        statusItem.button?.toolTip = "Marconio"
        statusItem.menu = makeStatusMenu()
        self.statusItem = statusItem

        menuBarViewStore.publisher
            .sink { [weak self] state in
                self?.updateStatusMenu(with: state)
            }
            .store(in: &cancellables)
    }

    private func makeStatusMenu() -> NSMenu {
        let menu = NSMenu()
        nowPlayingItem.isEnabled = false
        sourceItem.isEnabled = false
        menu.addItem(nowPlayingItem)
        menu.addItem(sourceItem)
        menu.addItem(playPauseItem)
        menu.addItem(.separator())

        menu.addItem(withTitle: "Open Marconio", action: #selector(openMarconio), keyEquivalent: "")

        let showInDockItem = NSMenuItem(
            title: "Show in Dock",
            action: #selector(toggleDockVisibility(_:)),
            keyEquivalent: ""
        )
        showInDockItem.state = showsInDock ? .on : .off
        menu.addItem(showInDockItem)

        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Marconio", action: #selector(quitMarconio), keyEquivalent: "q")
        return menu
    }

    private func updateStatusMenu(with state: MenuBarPlaybackState) {
        guard let playable = state.currentlyPlaying else {
            nowPlayingItem.title = "Nothing Playing"
            sourceItem.title = "NTS"
            sourceItem.isHidden = true
            playPauseItem.title = "Play"
            playPauseItem.isEnabled = false
            statusItem?.button?.toolTip = "Marconio"
            return
        }

        let program = playable.subtitle ?? playable.title
        nowPlayingItem.title = shortened(program)
        sourceItem.title = shortened(sourceDescription(for: playable))
        sourceItem.isHidden = false
        playPauseItem.isEnabled = state.playerState != .stopped
        playPauseItem.title = state.playerState == .playing ? "Pause" : "Resume"
        statusItem?.button?.toolTip = "\(program) — \(sourceDescription(for: playable))"
    }

    private func sourceDescription(for playable: MediaPlayable) -> String {
        guard let source = playable.source else {
            return "NTS"
        }

        switch source {
        case let .left(channel):
            let location = channel.now.details?.locationShort
            return ["NTS \(channel.channelName)", location]
                .compactMap { $0 }
                .joined(separator: " · ")
        case .right:
            return "NTS · Infinite Mixtape"
        }
    }

    private func shortened(_ text: String, limit: Int = 30) -> String {
        guard text.count > limit else {
            return text
        }
        return String(text.prefix(limit - 3)) + "..."
    }

    private func applyActivationPolicy() {
        NSApp.setActivationPolicy(showsInDock ? .regular : .accessory)
    }

    @objc private func openMarconio() {
        mainWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func toggleDockVisibility(_ sender: NSMenuItem) {
        let shouldShowInDock = !showsInDock
        UserDefaults.standard.set(shouldShowInDock, forKey: DefaultsKey.showInDock)
        sender.state = shouldShowInDock ? .on : .off
        applyActivationPolicy()
    }

    @objc private func togglePlayback() {
        menuBarViewStore.send(.playback(.togglePlayback))
    }

    @objc private func quitMarconio() {
        NSApp.terminate(nil)
    }
}
