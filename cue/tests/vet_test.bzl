"""Unit tests for starlark helpers
See https://bazel.build/rules/testing#testing-starlark-utilities
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//cue/private:versions.bzl", "TOOL_VERSIONS")

def _vet_test_impl(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, "0.5.0", TOOL_VERSIONS.keys()[0])
    return unittest.end(env)

# The unittest library requires that we export the test cases as named test rules,
# but their names are arbitrary and don't appear anywhere.
_t1_test = unittest.make(_vet_test_impl)

def vet_test_suite(name):
    unittest.suite(name, _t1_test)
