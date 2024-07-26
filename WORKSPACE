workspace(name = "tower-of-bazel")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_nodejs",
    sha256 = "0c2277164b1752bb71ecfba3107f01c6a8fb02e4835a790914c71dfadcf646ba",
    urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.8.5/rules_nodejs-core-5.8.5.tar.gz"],
)

http_archive(
    name = "build_bazel_rules_nodejs",
    sha256 = "a1295b168f183218bc88117cf00674bcd102498f294086ff58318f830dd9d9d1",
    urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.8.5/rules_nodejs-5.8.5.tar.gz"],
)

load("@build_bazel_rules_nodejs//:repositories.bzl", "build_bazel_rules_nodejs_dependencies")

build_bazel_rules_nodejs_dependencies()

load("@rules_nodejs//nodejs:repositories.bzl", "nodejs_register_toolchains")

node_version = "20.14.0"

nodejs_register_toolchains(
    name = "nodejs",
    node_version = node_version,
)

load("@build_bazel_rules_nodejs//:index.bzl", "npm_install")

npm_install(
    name = "npm",
    package_json = "//frontend/desktop:package.json",
    package_lock_json = "//frontend/desktop:package-lock.json",
    package_path = "frontend/desktop/",
    quiet = False,
    symlink_node_modules = True,
)

# Load the Ruby rules
load("@rules_ruby//ruby:deps.bzl", "rb_register_toolchains")

rb_register_toolchains(
    version_file = "//backend/app:.ruby-version",
)

# Rulesets Android / Java / Kotlin

_KOTLIN_COMPILER_VERSION = "1.7.20"

_KOTLIN_COMPILER_SHA = "5e3c8d0f965410ff12e90d6f8dc5df2fc09fd595a684d514616851ce7e94ae7d"

## Android

http_archive(
    name = "build_bazel_rules_android",
    sha256 = "cd06d15dd8bb59926e4d65f9003bfc20f9da4b2519985c27e190cddc8b7a7806",
    strip_prefix = "rules_android-0.1.1",
    urls = ["https://github.com/bazelbuild/rules_android/archive/v0.1.1.zip"],
)

load("@build_bazel_rules_android//android:rules.bzl", "android_sdk_repository")

android_sdk_repository(name = "androidsdk")

## Kotlin

http_archive(
    name = "io_bazel_rules_kotlin",
    sha256 = "15afe2d727f0dba572e0ce58f1dac20aec1441422ca65f7c3f7671b47fd483bf",
    url = "https://github.com/bazelbuild/rules_kotlin/releases/download/v1.7.0/rules_kotlin_release.tgz",
)

load("@io_bazel_rules_kotlin//kotlin:repositories.bzl", "kotlin_repositories", "kotlinc_version")

kotlin_repositories(
    compiler_release = kotlinc_version(
        release = _KOTLIN_COMPILER_VERSION,
        sha256 = _KOTLIN_COMPILER_SHA,
    ),
)

load("@io_bazel_rules_kotlin//kotlin:core.bzl", "kt_register_toolchains")

kt_register_toolchains()
