# FINS Parameters

**[RETURN TO TOP LEVEL README](../README.md)**

Parameters are used to genericize programmable logic IP cores. Unlike a Verilog "parameter" or a VHDL "generic", a FINS "parameter" is a constant definition that distributed through both the FINS JSON and code generation of HDL package files and other header-like files.

## JSON Schema

The top-level `params` field of the FINS JSON Schema is an array of dictionaries that define each parameter. These parameter dictionaries in turn have several fields listed in the table below:

> NOTE: Each element within the `params` dictionary array must have a unique `name` field.

| Key         | Type                     | Required | Description |
| ----------- | ------------------------ | -------- | ----------- |
| name        | string                   | YES      | The name of the parameter. |
| value       | string, bool, int, int[] | YES      | The value of the parameter. |
| description | string                   | NO       | The description of the parameter. |

Once defined, parameters may be used in place of literal values in two locations in the FINS JSON schema: [properties](properties.md) and [ports](ports.md). Where the `params['name']` is used for "Type" in these documentation pages is where a parameter can be used to set the value of a field. Parameters may also be linked to sub-ip to propagate the customization down the hierarchy. See the [Sub IP](sub-ip.md) documentation for more details on how this process works.

## Code Generation

Through code generation parameters are distributed to the various partitions of the IP design.

* **`name`_pkg.vhd**: This VHDL package defines a constant for each parameter. This package can be used by VHDL design files to have access to the parameters.
* **`name`_pkg.m**: This Octave/MATLAB script sets a field for each parameter on the `params` structure. This script can be used by build or simulation scripts to have access to the parameters.
* **`name`_pkg.py**: This Python script sets a field for each parameter on the `params` dictionary. This script can be used by build or simulation scripts to have access to the parameters.

For the `vivado` backend, constants are defined for each parameter at the beginning of the following code-generated scripts:

* **ip_create.tcl**: This script builds and packages the IP.
* **ip_simulate.tcl**: This script runs the simulation for the IP.

For the `quartus` backend, constants are defined for each parameter at the beginning of the following code-generated scripts:

* **ip_hw.tcl**: This script represents the packaged IP. The parameters are set as Platform Designer "parameters" of the IP.
* **ip_simulate.tcl**: This script runs the simulation for the IP.

**[RETURN TO TOP LEVEL README](../README.md)**