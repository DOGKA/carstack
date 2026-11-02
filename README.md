# CarStack

An experimental, full-screen YouTube web client for CarPlay on jailbroken
iOS 18. For passenger use; drivers must not interact while the vehicle is moving.

The current proof of concept targets iOS 18.6.2 on Dopamine rootless. It uses
the native CarPlay window scene, so touch events from the vehicle display are
delivered directly to its `WKWebView`.

## Why this works on iOS 18

iOS 18 moved the CarPlay shell into the private `DashBoard.framework`.
`DBApplicationController` now excludes apps that do not declare one of the
CarPlay entitlements returned by `CRCarPlayAppDeclaration`.

CarStack adds a CarPlay declaration entitlement, `CARAppFullScreen`, and the
legacy full-screen CarPlay scene configuration. The rootless package installs
the app under `/var/jb/Applications`.

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

This is an untested first proof of concept. If the app is indexed but its scene
does not launch on a real head unit, the next step is a narrowly scoped
DashBoard hook for `com.dogka.carstack`.

Netflix and other FairPlay-protected video services are outside the project
scope.

## License

GPL-3.0. See `LICENSE`.
