#!/usr/bin/env python3

import argparse
import dataclasses
import json
import os
import subprocess
from pathlib import Path


def contains_isystem_path(container: list[str], path: str) -> bool:
    was_isystem = False
    for x in container:
        if x == "-isystem":
            was_isystem = True
        elif was_isystem:
            was_isystem = False
            if x == path:
                return True

    return False


@dataclasses.dataclass
class FileInfo:
    directory: str
    arguments: list[str]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--workspace-root", required=True, help="path to workspace root"
    )
    parser.add_argument("--bazel-version", required=True, help="Bazel version to use")
    parser.add_argument("--bazelisk", required=True, help="path to bazelisk")
    args = parser.parse_args()

    bazelisk = os.path.realpath(args.bazelisk)

    os.chdir(args.workspace_root)

    Path(".bazelversion").write_text(args.bazel_version, encoding="utf-8")
    subprocess.run([bazelisk, "build", "//..."], check=True)

    with open("bazel-bin/compile_commands.json", encoding="utf-8") as f:
        compdb = json.load(f)

    file_info: dict[str, FileInfo] = {}
    for part in compdb:
        file_name = os.path.basename(part["file"])
        assert file_name not in file_info

        file_info[file_name] = FileInfo(
            directory=part["directory"], arguments=part["arguments"]
        )

    assert file_info.keys() == {
        "bina.cpp",
        "binb.cpp",
        "liba.cpp",
        "liba.hpp",
        "libb.cpp",
        "libb.hpp",
    }

    curdir = os.path.realpath(os.curdir)
    assert all(os.path.realpath(v.directory) == curdir for v in file_info.values())

    assert contains_isystem_path(
        file_info["bina.cpp"].arguments, "bazel-out/k8-fastbuild/bin/liba"
    )
    assert not contains_isystem_path(
        file_info["bina.cpp"].arguments, "bazel-out/k8-fastbuild/bin/libb"
    )

    assert contains_isystem_path(
        file_info["binb.cpp"].arguments, "bazel-out/k8-fastbuild/bin/libb"
    )
    assert not contains_isystem_path(
        file_info["binb.cpp"].arguments, "bazel-out/k8-fastbuild/bin/liba"
    )


if __name__ == "__main__":
    main()
