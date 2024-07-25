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
