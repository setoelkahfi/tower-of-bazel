load("@rules_ruby//ruby:defs.bzl", "rb_binary")

package(default_visibility = ["//:__subpackages__"])

rb_binary(
    name = "rails",
    main = "@bundle//bin:rails",
    deps = [
        "@bundle",
    ],
)
