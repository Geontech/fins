# FINS Node Parameters

**[RETURN TO TOP LEVEL README](../README.md)**

Parameters are used to genericize programmable logic IP cores or platforms. Unlike a Verilog "parameter" or a VHDL "generic", a FINS "parameter" is a constant definition that distributed through code generation of HDL package files and other header-like files.

## JSON Schema

The top-level `params` field of either the FINS Node or FINS Nodeset JSON Schemas is an array of dictionaries that define each parameter. These parameter dictionaries in turn have several fields listed in the table below:

> NOTE: Each element within the `params` dictionary array must have a unique `name` field.

| Key         | Type                     | Required | Description |
| ----------- | ------------------------ | -------- | ----------- |
| name        | string                   | YES      | The name of the parameter. |
| value       | string, bool, int, int[] | YES      | The value of the parameter. |
| description | string                   | NO       | The description of the parameter. |

Once defined, parameters may be used in place of literal values in two locations in the FINS Node JSON schema: [properties](properties.md) and [ports](ports.md). Where the `params['name']` is used for "Type" in these documentation pages is where a parameter can be used to set the value of a field. Parameters may also be linked to sub-ip in a FINS Node to propagate the customization down the hierarchy. See the [Sub IP](sub-ip.md) documentation for more details on how this process works.

Other than the parameters that are defined within the FINS Node JSON Schema, there is an additional special parameter defined in all FINS Node code generated outputs called `FINS_BACKEND`. This parameter contains a string with the backend name used when the FINS code generation was executed. This special parameter is useful for knowing which vendor's tools will be used to build and simulate the design.

## Code Generation

Through code generation parameters are distributed to the various partitions of the IP design. For the `core` backend of a FINS Node, the following files are generated:

* **`name`_pkg.vhd**: This VHDL package defines a constant for each parameter. This package can be used by VHDL design files to have access to the parameters.
* **`name`_pkg.m**: This Octave/MATLAB script sets a field for each parameter on the `params` structure. This script can be used by build or simulation scripts to have access to the parameters.
* **`name`_pkg.py**: This Python script sets a field for each parameter on the `params` dictionary. This script can be used by build or simulation scripts to have access to the parameters.

For the `core` backend of a FINS Nodeset, the following files are generated:

* **params.tcl**: This TCL script defines a constant for each parameter. This script can be sourced by any platform needing access to the parameters defined in the Nodeset.

For the `vivado` backend of a FINS Node, constants are defined for each parameter at the beginning of the following code-generated scripts:

* **ip_create.tcl**: This script builds and packages the IP.
* **ip_simulate.tcl**: This script runs the simulation for the IP.

For the `quartus` backend of a FINS Node, constants are defined for each parameter at the beginning of the following code-generated scripts:

* **ip_hw.tcl**: This script represents the packaged IP. The parameters are set as Platform Designer "parameters" of the IP.
* **ip_simulate.tcl**: This script runs the simulation for the IP.

**[RETURN TO TOP LEVEL README](../README.md)**