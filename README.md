# tower-of-bazel

> {fast, correct} + {polyglot} = {tower of bazel}

This simple repo demonstrates how to set up a multi-language monorepo.

## Before running it

This project is using `git LFS`. After cloning it, remember to run the following commands.

```bash
git lfs install
git lfs pull
```

## How to use

Main folder structure is to follow backend / frontent convention. If you're new to Bazel, read [the documentation](https://bazel.build/docs). Otherwise, query all targets in a given platform:

```bash
bazel query //backend/...
bazel query //frontend/...
```

### Tauri

Run debug Tauri app:

```bash
bazel run //frontend/desktop:dev
```

### Apple

Generate Xcode project:

```bash
bazel run //frontend/apple:xcodeproj
```

### Rails

Ruby on rails app:

```bash
bazel run //backend/app:rails
```

### Android

```bash
bazel mobile-install //frontend/android/src/main:app --start_app
```

## Credits

- [Tauri](https://github.com/marmos91/tauri-bazel-next-typescript).
- [Tauri on Bazel](https://github.com/setoelkahfi/tauri-on-bazel).
- [Apple](https://github.com/mattrobmattrob/bazel-ios-swiftui-template).
