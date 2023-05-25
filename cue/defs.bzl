"Public API re-exports"

def _run_cue_vet(cue_run, f, schema):
    """Return shell commands for testing 'srcs' with 'schema' using the 'cue vet' tool."""
    return """
echo "Vetting {path} with {schema}"
{cue_run} vet {path} {schema} || err=1
echo
""".format(
        cue_run = cue_run,
        path = f.path,
        schema = schema,
    )

def _cue_vet_test_impl(ctx):
    toolchain = ctx.toolchains["//cue:toolchain_type"]
    files = []
    files.extend(ctx.files.srcs)
    files.extend(ctx.files.schema)

    script = "\n".join(
        ["err=0"] +
        [_run_cue_vet(toolchain.cueinfo.target_tool_path, f, ctx.files.schema[0].path) for f in ctx.files.srcs] +
        ["exit $err"],
    )

    # Write the file, it is executed by 'bazel test'.
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = script,
        is_executable = True,
    )

    # To ensure the files needed by the script are available, we put them in
    # the runfiles.
    runfiles = ctx.runfiles(
        files = ctx.files.srcs + ctx.files.schema,
        transitive_files = toolchain.default.files,
    )
    return [DefaultInfo(runfiles = runfiles)]

_cue_vet_test = rule(
    attrs = {
        "srcs": attr.label_list(mandatory = True, allow_files = True),
        "schema": attr.label(mandatory = True, allow_single_file = True),
    },
    toolchains = ["//cue:toolchain_type"],
    implementation = _cue_vet_test_impl,
    test = True,
)

def cue_vet_test(**kwargs):
    _cue_vet_test(**kwargs)
