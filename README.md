# CarStack

An experimental, full-screen YouTube web client for CarPlay on jailbroken
iOS 18 and iOS 26. For passenger use; drivers must not interact while the
vehicle is moving.

The current proof of concept targets iOS 18.6.2 and iOS 26.0.1 on Dopamine
rootless. It uses the native CarPlay window scene, so touch events from the
vehicle display are delivered directly to its `WKWebView`.

## Why this works

iOS 18 moved the CarPlay shell into the private `DashBoard.framework`.
`DBApplicationController` now excludes apps that do not declare one of the
CarPlay entitlements returned by `CRCarPlayAppDeclaration`.

iOS 26 adds the native `com.apple.developer.carplay-video` declaration.
CarStack includes that declaration, keeps the iOS 18-compatible declaration,
and uses `CARAppFullScreen` with the full-screen CarPlay scene configuration.
The rootless package installs the app under `/var/jb/Applications`.

## Build

Requirements: Xcode, `ldid`, and `dpkg-deb`.

```sh
./scripts/build-deb.sh
```

The package is written to `build/packages`.

## Install

After GitHub Pages finishes deploying, add this source in Sileo:

```text
https://dogka.github.io/carstack/
```

## Status

This is an untested proof of concept. iOS 26 support has been verified against
the 26.0.1 system frameworks but still needs testing on a real head unit. If
the app is indexed but its scene does not launch, the next step is a narrowly
scoped DashBoard hook for `com.dogka.carstack`.

Netflix and other FairPlay-protected video services are outside the project
scope.

## License

GPL-3.0. See `LICENSE`.
