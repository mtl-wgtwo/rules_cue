"Public API re-exports"

def _cue_vet_impl(ctx):
    toolchain = ctx.toolchains["//cue:toolchain_type"]
    cli_args = []
    cli_args.extend(ctx.attr.options)
    # if ctx.attr.defaults_file:
    #     cli_args.extend(["--defaults", ctx.file.defaults_file.path])
    # cli_args.extend(["-o", ctx.outputs.output.path])
    # cli_args.extend(["--data-dir", "handbook"])

    files = []

    # files.extend(ctx.files.srcs)
    # files.append(ctx.file.defaults_file)
    ctx.actions.run(
        mnemonic = "Cue Vet",
        executable = toolchain.cueinfo.target_tool_path,
        arguments = cli_args,
        inputs = depset(
            direct = files,
            transitive = [toolchain.default.files],
        ),
        outputs = [ctx.outputs.output],
        progress_message = "Running: %s" % cli_args,
    )

_cue_vet = rule(
    attrs = {
        "options": attr.string_list(),
        "srcs": attr.label_list(mandatory = True, allow_files = True),
        "output": attr.output(mandatory = True),
    },
    toolchains = ["//cue:toolchain_type"],
    implementation = _cue_vet_impl,
)

def cue_vet(**kwargs):
    _cue_vet(**kwargs)
    pass
