A simple compilation database (`compile_commands.json`) generator for Bazel.

* Implemented with [aspects](https://bazel.build/extending/aspects).
* Works with generated sources.
* The generated `compile_commands.json` contains info for headers.
* Supports C++ (not C) builds with [rules_cc](https://github.com/bazelbuild/rules_cc) rules. Might work with custom C++ rules providing [CcInfo](https://bazel.build/rules/lib/providers/CcInfo), but see [Limitations](#limitations).

## Synopsys

`.bazelrc`
```
common --registry=https://raw.githubusercontent.com/snailbaron/registry/main
common --registry=https://bcr.bazel.build
```

`MODULE.bazel`
```bzl
bazel_dep(name = "snailbaron-compilation-database", version = "0.0.2")
```

`BUILD.bazel`
```bzl
load("@snailbaron-compilation-database//:compdb.bzl", "compilation_database")

compilation_database(
    name = "compdb",
    srcs = [
        "//:target_a",
        "//:target_b",
        # ...
    ],
)
```

In the terminal:
```sh
bazel build //:compdb
ln -s bazel-bin/compile_commands.json .
ln -s $(bazel info output_base)/external .
```

## Limitations

* C is not supported. `-xc++` is currently forcefully inserted for every file.
* The aspect requires the [CcInfo](https://bazel.build/rules/lib/providers/CcInfo) provider, propagates along the `deps` attribute, and looks into `srcs` and `hdrs` attributes to get the source files. This should work for the built-in/[rules_cc](https://github.com/bazelbuild/rules_cc) rules, and for custom C++ rules if they are similar enough (also provide [CcInfo](https://bazel.build/rules/lib/providers/CcInfo) and have `deps`/`srcs`/`hdrs` attributes with similar semantics).
* You must explicitly list all the targets you wish to generate the compilation database for. There is no way to generate it for `//...`.
* You cannot customize the name or location of the genrated file: it's always named `compile_commands.json` and located in the directory corresponding to where `compilation_database` is defined. Also, if you work with multiple configurations, you might want to symlink `bazel-out/<your-configuration>` instead of `bazel-bin`.
* Only tested on Linux right now, and not very rigorously.
