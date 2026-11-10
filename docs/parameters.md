# FINS Node Parameters

**[RETURN TO TOP LEVEL README](../README.md)**

Parameters are used to genericize programmable logic IP cores or platforms. By
default, a FINS parameter is a constant definition distributed through code
generation of HDL package files and other header-like files. A Node parameter
may additionally opt into promotion as a VHDL generic or Verilog parameter
with `promote_to_generic`; Application and System parameters remain propagated
configuration constants.

## JSON Schema

The top-level `params` field of the FINS Node, Application, and System JSON
schemas is an array of dictionaries that defines parameters. These parameter
dictionaries have the fields listed below:

> NOTE: Each element within the `params` dictionary array must have a unique `name` field.

| Key         | Type                     | Required | Description |
| ----------- | ------------------------ | -------- | ----------- |
| name        | string                   | YES      | The name of the parameter. |
| value       | string, bool, int, int[] | YES      | The value of the parameter. |
| description | string                   | NO       | The description of the parameter. |
| promote_to_generic | bool             | NO       | When true for a Node parameter, add it to the generated top-level VHDL generic/Verilog parameter list and expose it as a vendor IP customization parameter. Defaults to false. |
| hdl_type    | string                   | REQUIRED when promoted | HDL type used for the promoted generic, such as `boolean`, `integer`, `natural`, `positive`, or `string`. |

Once defined, parameters may replace literal values in supported Node
[properties](properties.md) and [ports](ports.md) fields. Application
parameters may be mapped into child Nodes, and Node parameters may be linked
to sub-IP to propagate customization down the hierarchy. See the
[Application](applications.md#application-json-schema-nodes) and
[Sub-IP](sub-ip.md) documentation for those mappings.

Other than the parameters that are defined within the FINS Node JSON Schema, there is an additional special parameter defined in all FINS Node code generated outputs called `FINS_BACKEND`. This parameter contains a string with the backend name used when the FINS code generation was executed. This special parameter is useful for knowing which vendor's tools will be used to build and simulate the design.

Promoted parameters remain package constants for compatibility and are also
declared as top-level HDL generics. The generated top wrapper passes them to
the generated or authored user core, which must declare matching generics when
it is authored outside FINS. Vivado packages them as editable IP parameters;
Quartus marks them as `HDL_PARAMETER` component parameters. Promotion is
compile-time configuration, not a run-time software property. Arbitrary array,
record, and unconstrained types are not portable GUI controls and should not be
promoted unless both vendor backends explicitly support their representation.

## Code Generation

Through code generation parameters are distributed to the various partitions of the IP design. For the `core` backend of a FINS Node, the following files are generated:

* **`name`_pkg.vhd**: This VHDL package defines a constant for each parameter. This package can be used by VHDL design files to have access to the parameters.
* **`name`_pkg.m**: This Octave/MATLAB script sets a field for each parameter on the `params` structure. This script can be used by build or simulation scripts to have access to the parameters.
* **`name`_pkg.py**: This Python script sets a field for each parameter on the `params` dictionary. This script can be used by build or simulation scripts to have access to the parameters.

For the `core` backend of a FINS System, the following files are generated:

* **params.tcl**: This TCL script defines a constant for each parameter. This script can be sourced by any platform needing access to the parameters defined in the System.

For the `vivado` backend of a FINS Node, constants are defined for each parameter at the beginning of the following code-generated scripts:

* **ip_create.tcl**: This script builds and packages the IP.
* **ip_simulate.tcl**: This script runs the simulation for the IP.

For the `quartus` backend of a FINS Node, constants are defined for each parameter at the beginning of the following code-generated scripts:

* **ip_hw.tcl**: This script represents the packaged IP. The parameters are set as Platform Designer "parameters" of the IP.
* **ip_simulate.tcl**: This script runs the simulation for the IP.

**[RETURN TO TOP LEVEL README](../README.md)**
