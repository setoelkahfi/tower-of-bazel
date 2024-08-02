load("@rules_rust//rust:defs.bzl", "rust_binary", "rust_doc")
load("@rust_axum_crates//:defs.bzl", "all_crate_deps")

package(default_visibility = ["//visibility:public"])

rust_binary(
    name = "app",
    srcs = ["src/main.rs"],
    deps = all_crate_deps(normal = True),
)

rust_doc(
    name = "app_doc",
    crate = ":app",
)