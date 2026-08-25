# Marconio

A focused macOS and iOS radio for listening to the live channels and mixtapes from [NTS](https://www.nts.live).

![](docs/images/playing_expanded.png)

NTS is listener supported, please consider supporting them in producing this fantastic free service. You can support them with the button below!

[Become a Supporter!](https://www.nts.live/supporters)

## Download

If you'd like to download Marconio, head on over to the [latest release page](https://github.com/brianmichel/Marconio/releases/latest) and download the `.dmg` attached to the release.

This app uses Sparkle to keep itself up to date. After you've installed one version of Marconio from the releases page you can continue to update to later versions from within the app.

## Features

- Listen to both live NTS channels and browse the mixtape archive.
- Send playback to an AirPlay speaker, soundbar, or TV from the control embedded in the LCD.
- See the current NTS programme in the LCD and in macOS Now Playing.
- Control playback with the media keys and macOS Control Centre.
- Keep Marconio in the menu bar and hide it from the Dock.

## Menu bar mode

Marconio can remain available without occupying space in the Dock. Open its menu bar icon to see the current programme and channel, pause or resume playback, reopen the main window, or quit the app.

Use **Show in Dock** in that menu to choose whether Marconio also appears in the Dock. Closing the main window does not stop the stream or remove the menu bar item.

## NTS metadata

While a live channel is tuned, Marconio refreshes the public programme metadata supplied by NTS and updates the LCD, menu bar, and system Now Playing information without restarting the stream. This includes the current show, channel, and location when NTS provides them.

The public live feed does not guarantee artist-and-track metadata. Live tracklists are a separate NTS supporter feature, so Marconio deliberately displays the programme information available from the public API rather than attempting to infer a track.

## AirPlay

Select the AirPlay icon at the lower-right corner of the LCD, then choose an available receiver. Routing is provided by macOS: the receiver must be compatible with AirPlay, powered on, and reachable from the Mac. A device appearing in Music does not imply that it is currently selected in Marconio; each app maintains its own playback route.

## Development

Open `Marconio.xcodeproj` in Xcode, or build and launch the macOS app from Terminal:

```sh
./script/build_and_run.sh --verify
```

Run the shared Swift package tests with:

```sh
swift test --package-path AppCore
```

## What is Marconio?

The project used to be called Lace. It became Marconio, a reference to [Guglielmo Marconi](https://en.wikipedia.org/wiki/Guglielmo_Marconi), when it needed a unique App Store name.
