load("@npm//@tauri-apps/cli:index.bzl", "tauri")

tauri(
    name = "dev",
    data = glob(["**"]) + [
        "@npm//next",
    ],
    templated_args = [
        "dev",
    ],
)

# Bundle doesn't work under bazel
tauri(
    name = "bundle",
    data = glob(["**"]) + [
        "@npm//next",
    ],
    templated_args = [
        "build",
    ],
)
