def _info_impl(repository_ctx):
    workspace_root = str(repository_ctx.workspace_root)

    workspace_root = workspace_root.replace("\\", "\\\\")
    workspace_root = workspace_root.replace('"', '\\"')

    repository_ctx.file("info.bzl", content = """\
workspace_root = "{}"
""".format(workspace_root))
    repository_ctx.file("BUILD.bazel", content = 'exports_files(["info.bzl"])')

info = repository_rule(
    implementation = _info_impl,
)
