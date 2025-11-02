load("@bazel_skylib//lib:paths.bzl", "paths")

_template_suffix = ".template"

def _expand_directory_impl(ctx):
    out_files = []
    for in_file in ctx.files.srcs:
        relative_path = paths.relativize(in_file.path, ctx.file.root.path)

        if in_file.basename.endswith(_template_suffix) and in_file.basename != _template_suffix:
            out_path = ctx.attr.out + "/" + relative_path.removesuffix(_template_suffix)
            out_file = ctx.actions.declare_file(out_path)
            out_files.append(out_file)

            ctx.actions.expand_template(
                template = in_file,
                output = out_file,
                substitutions = ctx.attr.substitutions,
            )
        else:
            out_path = ctx.attr.out + "/" + relative_path
            out_file = ctx.actions.declare_file(out_path)
            out_files.append(out_file)

            ctx.actions.symlink(output = out_file, target_file = in_file)

    return DefaultInfo(files = depset(out_files))

expand_directory = rule(
    implementation = _expand_directory_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "files in the directory to expand",
            mandatory = True,
            allow_files = True,
        ),
        "root": attr.label(
            doc = "root of the directory to expand",
            mandatory = True,
            allow_single_file = True,
        ),
        "substitutions": attr.string_dict(
            doc = "dictionary of substitutions to make",
            default = {},
        ),
        "out": attr.string(
            doc = "output directory to create",
            mandatory = True,
        ),
    },
)
