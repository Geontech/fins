# FINS Command-Line Reference

**[RETURN TO TOP LEVEL README](../README.md)**

The `fins` command accepts one or more FINS Node, Application, or System JSON
files and generates their requested outputs.

```text
fins [options] filepath [filepath ...]
```

## Options

| Option | Description |
| ------ | ----------- |
| `filepath [filepath ...]` | One or more FINS JSON files. Files are processed in the order given. |
| `-b BACKEND`, `--backend BACKEND` | Select a generator backend. The default is `core`. Use `vivado` or `quartus` for one vendor, repeat the option for both vendors, or use `all`. |
| `--part PART` | Override the top-level FPGA part from the JSON specification for this invocation. The selected part is propagated during recursive Node and sub-IP generation. |
| `-o NAME[=VALUE]`, `--option NAME[=VALUE]` | Pass a backend-specific option. Repeat for multiple options. This is a plugin extension point; the bundled `core`, `vivado`, and `quartus` generators currently define no options. |
| `-v`, `--verbose` | Include debug messages. |
| `-q`, `--quiet` | Show only warnings and errors. This option cannot be combined with `--verbose`. |
| `--version` | Print the installed FINS version and exit. |
| `-h`, `--help` | Print command help and exit. |

## Backend Selection

With no backend option, FINS generates only the vendor-neutral `core` output:

```bash
fins fins.json
```

Selecting a vendor generates the common core output first and then that
vendor's files:

```bash
fins -b vivado fins.json
fins -b quartus fins.json
```

Generate both vendor backends with either form below:

```bash
fins -b all fins.json
fins -b vivado -b quartus fins.json
```

`all` cannot be combined with another `--backend` option. Repeated backend
names are ignored after their first occurrence.

## Multiple Input Files

The same options apply to every input file in one invocation:

```bash
fins -b all node.json application.json
```

Each file is processed relative to its own containing directory, so paths in
the FINS JSON remain relative to that specification.

## Part Override

Use `--part` for a temporary command-line override without editing the JSON:

```bash
fins -b vivado --part xc7z020clg484-1 fins.json
```

For specifications delivered to multiple vendors, prefer the JSON `parts`
mapping when each backend needs a different part.

## Exit Status

The command exits with status 0 only when every requested input and backend
completes successfully. Invalid CLI configuration, validation failures, and
generator failures return a nonzero status suitable for CI use. Expected
generation failures are reported as concise errors rather than being logged
and treated as successful generation.

**[RETURN TO TOP LEVEL README](../README.md)**
