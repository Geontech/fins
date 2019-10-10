# FINS Nodeset Integration

**[RETURN TO TOP LEVEL README](../README.md)**

A FINS Nodeset is an integration concept with its own separate JSON schema to describe the collection of FINS nodes that exist within a programmable logic bitstream. The primary purpose of creating this file is to aggregate the Node information so that the FINS software package may control properties and communicate with ports in the programmable logic build.

## JSON Schema

A Nodeset has its own schema to enable integration with software. See the table below for the details of all the fields:

| Key         | Type   | Required | Default Value | Description |
| ----------- | ------ | -------- | ------------- | ----------- |
| name        | string | YES      |               | The name of the Nodeset, only used for identification purposes. |
| base_offset | uint   | NO       |             0 | The base address offset of the bus used to communicate with the FINS nodes. |
| nodes       | dict[] | YES      |               | A dictionary array that contains a description of each node. |

Each dictionary element of the `nodes` dictionary array field has the following fields:

| Key               | Type              | Required | Default Value | Description |
| ----------------- | ----------------- | -------- | ------------- | ----------- |
| fins_path         | string            | YES      |               | The path to the *generated* FINS Node JSON file of the IP node. |
| module_name       | string            | YES      |               | If `properties_offset` is a dictionary, this field is used to infer the offset. The name of the instantiated IP in the block design defined above. |
| interface_name    | string            | YES      |               | If `properties_offset` is a dictionary, this field is used to infer the offset. The name of the bus interface used to control and status the properties. |
| properties_offset | uint -OR- string  | YES      |               | The base offset of the address region used to access this node. If a string type, this field is a path to the block design in which the decode of the properties interface is located. This path must end in `.qsys` for Intel Platform Designer or `.bd` for Vivado IP Integrator, and it used to infer the offset. |
| ports_producer    | string            | NO       |               | NOT IMPLEMENTED YET. |
| ports_consumer    | string            | NO       |               | NOT IMPLEMENTED YET. |

## Code Generation

Code generation of a FINS Nodeset JSON file just results in a fully-populated JSON located in the **./gen/core/** directory of where the `fins` executable was run. This generated FINS Nodeset JSON file should be used as an input to the FINS software package.

**[RETURN TO TOP LEVEL README](../README.md)**