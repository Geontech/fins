# FINS Node Ports

**[RETURN TO TOP LEVEL README](../README.md)**

FINS Ports are a way to standardize data and metadata communication within the programmable logic. FINS generates an AXI4-Stream bus interpreter module which transmits data and metadata in parallel through the AXI4-Stream TDATA and TUSER fields, respectively.

## JSON Schema

The top-level `ports` field of the FINS Node JSON Schema in turn has two fields.

> NOTE: In the tables below, `param['name']` is used for "Type" for some fields. This indicates that a string containing the name of a FINS parameter can be used in place of the value. However, ensure the FINS parameter has the same type as expected by the field!

| Key   | Type   | Required | Default Value | Description |
| ----- | ------ | -------- | ------------- | ----------- |
| ports | dict[] | NO       |               | An array of FINS Port definitions which are ultimately generated as AXI4-Stream buses. A `ports` object may instead contain only raw `hdl` ports. |
| hdl   | dict[] | NO       |               | An array of HDL port definitions which are ultimately generated as raw VHDL ports. See below for more information on the schema for each element of the array. |

## HDL Ports

### JSON Schema

Each dictionary element of the `hdl` dictionary array field has the following fields:

> NOTES: Each element within the `hdl` dictionary array must have a unique `name` field.

| Key                  | Type                    | Required | Default Value | Value Restrictions | Description |
| -------------------- | ----------------------- | -------- | ------------- | ------------------ | ----------- |
| name                 | string                  | YES      |               |                    | The name of the VHDL port. This must be unique within a FINS IP. |
| direction            | string                  | YES      |               | in<br />out        | The direction of the VHDL port. |
| bit_width            | uint or `param['name']` | YES      |               |                    | The bit width of the VHDL port. |

### Records

FINS Ports in a FINS Node JSON file autogenerate into an interpreter module that uses records defined in the VHDL package file. This module interacts with user HDL through the `ports_hdl_in` and `ports_hdl_out` record interfaces which are defined in the auto-generated VHDL package file. All HDL ports that have a `direction` of "in" are transported to the HDL user core on the `ports_hdl_in` record, and all HDL ports that have a `direction` of "out" are transported to the HDL user core on the `ports_hdl_out` record.

## FINS Ports

### JSON Schema

Each dictionary element of the FINS `ports` dictionary array field has the following fields:

> NOTE: Each element within the FINS `ports` dictionary array must have a unique `name` field. `data` is required. Optional `metadata` is transported alongside that data in AXI4-Stream `TUSER`.

| Key                  | Type                    | Required | Default Value | Value Restrictions | Description |
| -------------------- | ----------------------- | -------- | ------------- | ------------------ | ----------- |
| name                 | string                  | YES      |               |                    | The name of the port. This must be unique within a FINS IP. |
| direction            | string                  | YES      |               | in<br />out        | The bus direction of the port. This generally corresponds to the HDL port direction - except for the "tready" signal. |
| supports_backpressure | bool or `param['name']` | NO       | false         |                    | A flag indicating if the port supports backpressure. Backpressure manifests as the "tready" signal of the AXI4-Stream bus. |
| supports_byte_enable | bool or `param['name']` | NO       | false         |                    | A flag indicating whether the port carries per-byte validity information. When true, the generated AXI4-Stream interface includes `TKEEP`, and the corresponding FINS port record includes a `keep` field. |
| num_instances        | uint or `param['name']` | NO       | 1             | >=1                | The number of instances of this port. Each instance is independent and has unique control signals. |
| use_pipeline         | bool or `param['name']` | NO       | true          |                    | A flag indicating if a pipeline should be inserted in the port. If true, input and output ports will have a 1 clock latency. |
| data                 | dict                    | YES      |               |                    | A dictionary that describes the data characteristics. Its individual fields may reference parameters. This dictionary determines how the bus interpreter module decodes the `TDATA` signal. |
| metadata             | dict[]                  | NO       |               |                    | Optional sideband fields packed into the AXI4-Stream `TUSER` signal in declaration order. |

### Byte Enables and `TKEEP`

When `supports_byte_enable` is `true`, FINS adds a `TKEEP` signal to the
generated AXI4-Stream interface. Each bit of `TKEEP` identifies whether the
corresponding byte lane of `TDATA` contains valid data for that transaction.

The generated `TKEEP` width is:

```
ceil((data.bit_width * data.num_samples * data.num_channels) / 8)
```

The same value is exposed to user HDL as the `keep` field of the FINS port
record. When `supports_byte_enable` is omitted or `false`, neither the
`TKEEP` signal nor the record's `keep` field is generated.

The `data` dictionary field has the following fields:

| Key          | Type                    | Required | Default Value | Value Restrictions    | Description |
| ------------ | ----------------------- | -------- | ------------- | --------------------- | ----------- |
| bit_width    | uint or `param['name']` | NO       | 16            | >= 8, <= 4096<b>*</b> | The bit width of a single sample of data. If `is_complex` is true, then this value is the bit width for BOTH real and imaginary components. Since this value is for a single sample, it should not change when `num_samples` or `num_channels` change. |
| is_complex   | bool or `param['name']` | NO       | false         |                       | A flag indicating if a sample of data has real and imaginary parts. The real and imaginary parts MUST have the same bit width, and their summed bit widths should be put in the `bit_width` field. If this value is true, then real data is packed in the LSBs of the sample. |
| is_signed    | bool or `param['name']` | NO       | false         |                       | A flag indicating if a sample of data is interpreted as a signed 2's complement value; otherwise, it is interpreted as an unsigned value. This value applies to the individual real and imaginary components when `is_complex` is true. |
| num_samples  | uint or `param['name']` | NO       | 1             | >= 1                  | The number of simultaneous samples that are communicated through the data bus per transaction for a single channel. When `num_samples` is > 1, the first sample is packed in the LSBs and the last sample is packed in the MSBs. |
| num_channels | uint or `param['name']` | NO       | 1             | >= 1                  | The number of parallel channels that are communicated through the data bus. When `num_channels` is > 1, the first channel is packed in the LSBs and the last channel is packed in the MSBs.  |

> **\*** The maximum `bit_width` for `num_samples`=1 and `num_channels`=1 is 4096. The maximum `bit_width` is divided by the `num_samples` and/or `num_channels` since the total data width is capped at 4096. For example, when `num_samples`=2 and `num_channels`=4, the maximum `bit_width` is 4096/2/4=512.

Each dictionary element of the `metadata` dictionary array field has the following fields:

> NOTE: Each element within the `metadata` dictionary array must have a unique `name` field.

| Key          | Type                    | Required | Default Value | Value Restrictions | Description |
| ------------ | ----------------------- | -------- | ------------- | ------------------ | ----------- |
| name         | string                  | YES      |               |                    | The name of the metadata. This must be unique within a port. |
| bit_width    | uint or `param['name']` | NO       | 16            | >= 1<b>*</b>       | The bit width of the metadata. If `is_complex` is true, then this value is the bit width for BOTH real and imaginary components. |
| is_complex   | bool or `param['name']` | NO       | false         |                    | A flag indicating if the metadata has real and imaginary parts. The real and imaginary parts MUST have the same bit width, and their summed bit widths should be put in the `bit_width` field. If this value is true, then real data is packed in the LSBs of the sample. |
| is_signed    | bool or `param['name']` | NO       | false         |                    | A flag indicating if the metadata is interpreted as a signed 2's complement value; otherwise, it is interpreted as an unsigned value. This value applies to the individual real and imaginary components when `is_complex` is true. |

> **\*** The `bit_width` for all metadata fields must sum to <= 4096.

### FINS Port Records

FINS Ports in a FINS Node JSON file autogenerate into an interpreter module that uses records defined in the VHDL package file. This module interacts with user HDL through the `ports_in` and `ports_out` record interfaces which are defined in the auto-generated VHDL package file. `ports_in` contains the signals that go from the bus interpreter decode module to user HDL, and `ports_out` contains the signals that go from user HDL to the bus interpreter decode module. These top-level records are an array if `num_instances > 1`, and they have a field for each port that can interact with other HDL. Each port in turn has fields that specify the interface with the user HDL. The fields of each port record depend on the direction and if backpressure is supported. The table below shows all available combinations:

| `direction` | `supports_backpressure` | `metadata` exists | ports_in Record Fields                                       | ports_out Record Fields                 |
| ----------- | ----------------------- | ----------------- | ------------------------------------------------------------ | --------------------------------------- |
| in          | true                    | false             | clk<br />resetn<br />valid<br />last<br />data               | ready                                   |
| in          | true                    | true              | clk<br />resetn<br />valid<br />last<br />data<br />metadata | ready                                   |
| in          | false                   | false             | clk<br />resetn<br />valid<br />last<br />data               |                                         |
| in          | false                   | true              | clk<br />resetn<br />valid<br />last<br />data<br />metadata |                                         |
| out         | true                    | false             | clk<br />resetn<br />ready                                   | valid<br />last<br />data               |
| out         | true                    | true              | clk<br />resetn<br />ready                                   | valid<br />last<br />data<br />metadata |
| out         | false                   | false             | clk<br />resetn                                              | valid<br />last<br />data               |
| out         | false                   | true              | clk<br />resetn                                              | valid<br />last<br />data<br />metadata |

When `supports_byte_enable` is `true`, a `keep` field accompanies `data` in
the same record.

The diagram below has a visual representation of how example ports are converted to Port records from AXI4-Stream buses:

![](./port_types.png)

The type of the "data" field of `ports_in` and `ports_out` records depends on the characteristics of the data definition. The table below shows the possible combinations of data types.

| `num_channels` | `num_samples` | `is_complex` | `is_signed` | Data Type                                           |
| -------------- | ------------- | ------------ | ----------- | --------------------------------------------------- |
| 1              | 1             | false        | false       | unsigned                                            |
| 1              | 1             | false        | true        | signed                                              |
| 1              | 1             | true         | false       | record(i:unsigned, q:unsigned)                      |
| 1              | 1             | true         | true        | record(i:signed, q:signed)                          |
| 1              | > 1           | false        | false       | samples[] unsigned                                  |
| 1              | > 1           | false        | true        | samples[] signed                                    |
| 1              | > 1           | true         | false       | samples[] record(i:unsigned, q:unsigned)            |
| 1              | > 1           | true         | true        | samples[] record(i:signed, q:signed)                |
| > 1            | 1             | false        | false       | channels[] unsigned                                 |
| > 1            | 1             | false        | true        | channels[] signed                                   |
| > 1            | 1             | true         | false       | channels[] record(i:unsigned, q:unsigned)           |
| > 1            | 1             | true         | true        | channels[] record(i:signed, q:signed)               |
| > 1            | > 1           | false        | false       | channels[] samples[] unsigned                       |
| > 1            | > 1           | false        | true        | channels[] samples[] signed                         |
| > 1            | > 1           | true         | false       | channels[] samples[] record(i:unsigned, q:unsigned) |
| > 1            | > 1           | true         | true        | channels[] samples[] record(i:signed, q:signed)     |

The type of the "metadata" field of `ports_in` and `ports_out` records depends on the characteristics of the metadata definition. The `metadata` record itself contains fields that have the names of each metadata field. The combinations of different types of each metafield is shown in the table below.

| `is_complex` | `is_signed` | Metadata Type                  |
| ------------ | ----------- | ------------------------------ |
| false        | false       | unsigned                       |
| false        | true        | signed                         |
| true         | false       | record(i:unsigned, q:unsigned) |
| true         | true        | record(i:signed, q:signed)     |

## Code Generation

Code generation is performed in two steps. The ports schema is analyzed and populated with default values and additional fields, and then the transformed schema is passed to Jinja2 templates for code generation. When the `ports` top-level field exists in the FINS Node JSON file, the following output files are generated:

### `name`_pkg.vhd

This VHDL package defines the ports records and their associated signals. This package is used by the bus interpreter decode modules.

For ease of use, four conversion functions are provided in the pkg file for each port's data and metadata. These functions convert between the custom record types and std_logic_vector's, and their naming conventions are listed below:

* f_serialize_[IP_NAME]_[PORT_NAME]_data()
* f_unserialize_[IP_NAME]_[PORT_NAME]_data()
* f_serialize_[IP_NAME]_[PORT_NAME]_metadata()
* f_unserialize_[IP_NAME]_[PORT_NAME]_metadata()

### `name`_axis.vhd

This VHDL module decodes data and metadata communication on the AXI4-Stream bus into record signals for each port.

### `name`_axis_verify.vhd

This VHDL module defines file IO processes for sourcing and sinking data/metadata between text files and the test bench. The file paths of these text files are generics for the module, and they are relative to where the simulation is executed within the vendor tools. The table below has a listing of the execution directories and relative file paths from the FINS simulation execution directory back to the root of the IP.

| Vendor Tool    | Version | Execution Directory                        | Relative Path      |
| -------------- | ------- | ------------------------------------------ | ------------------ |
| Xilinx Vivado  | 2022.2, 2025.1.1 | project/vivado/`name`.sim/sim_1/behav/xsim | ../../../../../../ |
| Intel ModelSim | 19.4    | project/quartus/mentor                     | ../../../          |

The source and sink text files require a specific format for file IO processes to be able to read the information properly. The following rules apply to these simulation sink/source files.

1. All information in the text file is represented in ASCII hex characters.
2. Each AXI4-Stream transaction is a row within the text file.
3. Each transaction is space-separated into `TLAST`, `TDATA`, optional `TUSER`, and optional `TKEEP` fields.
4. Each transaction is required to start with a single hex character that represents the TLAST field of the AXI4-Stream bus protocol.
5. After the TLAST field, the transaction row contains the TDATA field.
6. If there is metadata communicated through the port, the TUSER field is present after the TDATA field in the transaction row.
7. If `supports_byte_enable` is true, the TKEEP field is present last, after TDATA and any TUSER field.

An example of a simulation source file for a port that has both data (TDATA) and metadata (TUSER) is below. This example contains two AXI4-Stream packets, each with 4 transactions.

```
0 0000 00010001
0 0101 00010001
0 0202 00010001
1 0303 00010001
0 0404 00010001
0 0505 00010001
0 0606 00010001
1 0707 00010001
```

The generated MATLAB/Octave `name_axis_file_write.m` and
`name_axis_file_read.m` helpers use this same layout. Metadata fields are
packed in JSON declaration order, with the first field occupying the
least-significant TUSER bits. Complex fields place the real component below
the imaginary component. The helpers represent metadata once per packet: the
writer repeats it for every transaction in that packet, and the reader uses
the first transaction's metadata. Full TDATA and TUSER words may be wider than
52 bits, but each real or imaginary component supplied as a MATLAB/Octave
numeric value must be at most 52 bits to remain exactly representable.

**[RETURN TO TOP LEVEL README](../README.md)**
