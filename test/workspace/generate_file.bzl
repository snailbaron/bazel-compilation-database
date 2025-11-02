def _generate_file_impl(ctx):
    ctx.actions.write(
        output = ctx.outputs.out,
        content = ctx.attr.content,
    )

generate_file = rule(
    implementation = _generate_file_impl,
    attrs = {
        "out": attr.output(
            mandatory = True,
            doc = "label of the file to generate",
        ),
        "content": attr.string(
            mandatory = True,
            doc = "content of the generated file",
        ),
    },
)
