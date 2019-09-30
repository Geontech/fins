# Tutorial: FINS Node Power Converter

**[RETURN TO TOP LEVEL README](../README.md)**

In this tutorial, we will create a simple power conversion firmware IP module using FINS, Intel Quartus Prime Pro 19.1, and Xilinx Vivado 2019.1. Make sure you have installed `fins`, the `fins-quartus` backend, and the `fins-vivado` backend!

## Step 1: Creating the Firmware IP Node Specification JSON File

Create a new directory called **power_converter** in a convenient place on your system where your user has permissions. All filepaths for the rest of this tutorial will be relative to this directory, and it will be referenced as the "IP root" directory.

```bash
$ mkdir power_converter
$ cd power_converter
```

Using your favorite text editor, create a file called **fins.json** in the **power_converter** directory with the following contents.

```json
{
  "name":"power_converter",
  "params":[
    { "name":"IQ_DATA_WIDTH",    "value":32 },
    { "name":"POWER_DATA_WIDTH", "value":16 }
  ],
  "properties":{
    "addr_width":16,
    "data_width":32,
    "is_addr_byte_indexed":false,
    "properties":[
      { "name":"gain", "type":"read-write-data", "width":16, "default_values":1 }
    ]
  },
  "ports":{
    "ports":[
      {
        "name":"iq",
        "direction":"in",
        "data":{ "bit_width":"IQ_DATA_WIDTH", "is_complex":true, "is_signed":true }
      },
      {
        "name":"power",
        "direction":"out",
        "data":{ "bit_width":"POWER_DATA_WIDTH", "is_signed":true }
      }
    ]
  }
}
```

In the **fins.json** file we just created, we have defined:

1. Two "params" which translate into constants in an auto-generated VHDL package. See [here](parameters.md) for more information about parameters.
2. A "properties" interface with a single property called "gain". The "properties" interface is used to auto-generate an AXI4-Lite decode module that gives us software control of "gain". The "read-write-data" property type is the most commonly used type, and it defines a readable and writable property whose data is available to our user code. See [here](properties.md) for more information about properties.
3. A "ports" interface wtih two ports: "iq" input and "power" output. Notice that the parameters we defined earlier are used instead of literal values. The ports are defined so that our FINS IP will have complex signed IQ input and a real-only signed power output. See [here](properties.md) for more information about properties.

> NOTE: The parameters, properties, and ports definitions we created above used minimal options to define their characteristics. We were able to take advantage of the defaults of different dictionary fields. For instance, the "is_complex" field of the "power" port was not set since the default is `false`. Make sure you familiarize yourself with the default settings that are located in the "JSON Schema" sections of the various documentation pages!

## Step 2: Auto-generating HDL

Next, run `fins` using the **fins.json** file as the command line argument.

> NOTE: The default `--backend` option is the "core" backend. This backend provides the code generation without any vendor-specific scripts.

```bash
$ fins fins.json
```

Once that operation completes, inspect the **./gen/core** directory to find the files listed below.

* **power_converter.json**: This is the implemented FINS Node JSON data used to generate the templates, and it has all default values set and parameter names converted to literal values. It is a good place to check to make sure that the **fins.json** file that you wrote is getting interpreted properly.
* **power_converter_axis.vhd**: This is a ports interpreter module to decode the AXI4-Stream bus into port records.
* **power_converter_axis_verify.vhd**: This is a testbench module that reads and writes files with AXI4-Stream bus data.
* **power_converter_properties.md**: This is a Markdown documentation file that lists the properties and their addresses.
* **power_converter_axilite.vhd**: This is a properties decode module to convert the AXI4-Lite memory-mapped bus into property records.
* **power_converter_axilite_verify.vhd**: This is a testbench package that contains procedures for reading/writing properties and verifying the address space.
* **power_converter_swconfig.vhd**: This is a properties decode module to convert the Software Configuration memory-mapped bus into property records.
* **power_converter_swconfig_verify.vhd**: This is a testbench package that contains procedures for reading/writing properties and verifying the address space.
* **power_converter.vhd**: This is a top-level code stub that instantiates the ports and properties interfaces to give a starting point for the top-level source file.
* **power_converter_tb.vhd**: This is a top-level code stub that provides a simple testbench for testing the ports and properties interfaces.
* **power_converter_pkg.vhd**: This is the source package file that defines parameters, property records, and port records.
* **power_converter_pkg.m**: This is an Octave script that defines parameters and port structures for usage in simulation source generation and sink validation.
* **power_converter_pkg.py**: This is a Python script that defines parameters and port structures for usage in simulation source generation and sink validation.

Next, copy the top-level code stubs to a new folder at the IP root.

```bash
$ mkdir hdl
$ cp gen/core/power_converter.vhd hdl/
```

## Step 3: Adding the functional code

Now we want to add the power conversion functional code to the top-level source file stub. Add the following code to the "Signals" section of **hdl/power_converter.vhd**.

```vhdl
  -- Data processing
  constant MODULE_LATENCY  : natural := 4;
  signal input_i           : signed(IQ_DATA_WIDTH/2-1 downto 0);
  signal input_q           : signed(IQ_DATA_WIDTH/2-1 downto 0);
  signal input_squared_i   : signed(IQ_DATA_WIDTH-1 downto 0);
  signal input_squared_q   : signed(IQ_DATA_WIDTH-1 downto 0);
  signal power_full_scale  : signed(IQ_DATA_WIDTH-1 downto 0);
  signal power             : signed(POWER_DATA_WIDTH-1 downto 0);
  signal valid_delay_chain : std_logic_vector(MODULE_LATENCY-1 downto 0);
  signal last_delay_chain  : std_logic_vector(MODULE_LATENCY-1 downto 0);
```

Add the following code to the "User Code" section of **hdl/power_converter.vhd**.

```vhdl
  -- Synchronous process for the user code of the power conversion function
  s_user_code : process (s_axis_iq_aclk)
  begin
    if (rising_edge(s_axis_iq_aclk)) then
      -- Data Registers
      input_i          <= ports_in.iq.data.i;
      input_q          <= ports_in.iq.data.q;
      input_squared_i  <= input_i * input_i;
      input_squared_q  <= input_q * input_q;
      power_full_scale <= resize(
        input_squared_i + input_squared_q,
        power_full_scale'length
      ); -- Resize drops extra signed bit from previous multiplication operation
      power <= resize(
        power_full_scale(power_full_scale'length-1 downto power_full_scale'length-POWER_DATA_WIDTH) * signed(props_control.gain.wr_data),
        power'length
      );
      -- Control Registers
      if (s_axis_iq_aresetn = '0') then
        valid_delay_chain <= (others => '0');
        last_delay_chain  <= (others => '0');
      else
        valid_delay_chain(0) <= ports_in.iq.valid;
        last_delay_chain(0)  <= ports_in.iq.last;
        for ix in 1 to MODULE_LATENCY-1 loop
          valid_delay_chain(ix) <= valid_delay_chain(ix-1);
          last_delay_chain(ix)  <= last_delay_chain(ix-1);
        end loop;
      end if;
    end if;
  end process s_user_code;

  -- Assign outputs
  ports_out.power.data  <= power;
  ports_out.power.valid <= valid_delay_chain(MODULE_LATENCY-1);
  ports_out.power.last  <= last_delay_chain(MODULE_LATENCY-1);
```

Save the file.

## Step 4: Building the IP with Vivado and Quartus

Modify your **fins.json** file to add the following code after the `ports` top-level key. Remember to use a comma after the closing curly brace (`}`) of `ports`!

```json
  "filesets":{
    "source":[
      { "path":"gen/core/power_converter_pkg.vhd" },
      { "path":"gen/core/power_converter_axis.vhd" },
      { "path":"gen/core/power_converter_axilite.vhd" },
      { "path":"hdl/power_converter.vhd" }
    ],
    "sim":[
      { "path":"gen/core/power_converter_axilite_verify.vhd" },
      { "path":"gen/core/power_converter_axis_verify.vhd" },
      { "path":"gen/core/power_converter_tb.vhd" }
    ]
  }
```

The `filesets` top-level key indicates which files are used in the HDL project. Notice that most of the files are located in the **gen/core/** directory. These files are auto-generated and accordingly updated with the `fins` code generator executable. Since FINS manages these files, the burden of creating and maintaining these files is removed from the developer! The `filesets` key also contains references to scripts that are executed at different points in the build and simulation process (there is an example below).

To auto-generate scripts and a **Makefile** and then build the IP with Xilinx Vivado, execute the following commands.

> NOTE: Make sure you have sourced the **settings64.sh** script for the version of Xilinx Vivado that you want to use.

```bash
$ fins -b vivado fins.json
$ make UseGui=1
```

The `UseGui=1` make variable tells FINS to launch the Vivado GUI to perform the operations. Once the operations have completed, check the "TCL Console" to make sure that there were no errors. Take a moment to look at the project hierarchy and the IP packaging details, and then close Vivado. Look inside the **./project/vivado** directory and you will find the **power_converter.xpr** IP project file that we just closed.

Next, inspect the **./gen/vivado** directory to find the files listed below.

* **ip_create.tcl**: This is the script that the **Makefile** used to create a Vivado project with the source and simulation files and to package the IP.
* **ip_simulate.tcl**: This is the script that will run the simulation in the next step of this tutorial.

To auto-generate scripts and a **Makefile** and then build the IP with Intel Quartus Prime Pro, execute the following commands.

> NOTE: Make sure you have the path to the `quartus` executable on your `PATH` environmental variable for the version of Intel Quartus that you want to use.

```bash
$ make clean
$ fins -b quartus fins.json
$ make UseGui=1
```

The `UseGui=1` make variable tells FINS to display the Quartus messages to the command window. Since Quartus has a more command-line flow, the Quartus GUI is not opened. Once the operations have completed, check the command line console output to make sure that there were no errors. Look inside the **./project/quartus** directory and you will find the **power_converter.qpf** IP project file that was created and the **power_converter.ip** IP definition file.

Next, inspect the **./gen/quartus** directory to find the files listed below.

* **ip_hw.tcl**: This a Platform Designer IP definition file that is used when adding an IP to a Platform Designer System.
* **ip_create.tcl**: This is the script that the **Makefile** used to create a Quartus project with the source and simulation files and to package the IP.
* **ip_simulate.tcl**: This is the script that will run the simulation in the next step of this tutorial.

## Step 5: Simulating the IP with ModelSim and Vivado

First we need to create a simulation source file for the "iq" input port. Create a directory **./sim_data** in the IP root to contain our simulation files. **./sim_data** is the default simulation file source/sink location of the generated testbench **gen/core/power_converter_tb.vhd**.

```
$ mkdir sim_data
```

Create a text file called **sim_source_iq.txt** in the **sim_data** directory with the contents below. We are using the name **sim_source_iq.txt** since it follows the default file naming convention of the generated testbench **gen/core/power_converter_tb.vhd** when referencing simulation source/sink files. For simulation source files that read data from a text file and send it to an input port, the convention is `sim_source_[PORT_NAME].txt`. For simulation sink files that write data to a text file from an output port, the convention is `sim_sink_[PORT_NAME].txt`.

```
0 00010001
0 00020002
0 00030003
0 00040004
0 00050005
0 00060006
0 00070007
1 00080008
```

The data format used above for **sim_source_iq.txt** is a hex-character-only text file for AXI4-Stream. The first column is always the TLAST signal. If only data exists in the port, then the second column is the TDATA signal. If only metadata exists in the port, then the second column is the TUSER signal. If both data and metadata exist in the port, then the second column is the TDATA signal and the third column is the TUSER signal.

Execute the following command to run the simulation with the ModelSim GUI.

> NOTE: This command assumes that you have followed this tutorial exactly and results of the the previous steps are located in the repository.

```bash
$ make sim UseGui=1
```

In the ModelSim GUI, notice the "***** SIMULATION PASSED *****" message in the Transcript window. Click "Yes" in the dialog message that asks if you want to quit.

Execute the following commands to run the simulation with the Vivado GUI.

```bash
$ make clean
$ fins -b vivado fins.json
$ make
$ make sim UseGui=1
```

In the Vivado GUI, notice the "***** SIMULATION PASSED *****" message in the Tcl Console window. Close the Vivado GUI.

At this point, we have run the default simulation testbench which verifies that the properties exist and can be written and verifies that the ports exist and correctly pass data. However, we have not verified that the output data of the IP is correct. In order to verify the output data of the IP, we need create a script that checks the simulation output files. Create a directory called **scripts** in the IP root.

```bash
$ mkdir scripts
```

Within the **scripts** directory, create a file called **verify_sim.py** with the following contents.

```python
#!/usr/bin/env python3
import sys

# Import auto-generated parameters file
sys.path.append('gen/core/')
import power_converter_pkg

# Open our simulation input
sim_source_data = {'last':[], 'data':{'i':[], 'q':[]} }
with open('sim_data/sim_source_iq.txt', 'r') as sim_source_file:
    for sim_source_line in sim_source_file:
        line_data = sim_source_line.split(' ')
        sim_source_data['last'].append(int(line_data[0], 16))
        sim_source_data['data']['q'].append(int(line_data[1][0:4], 16))
        sim_source_data['data']['i'].append(int(line_data[1][4:8], 16))

# Open our simulation output
sim_sink_data = {'last':[], 'data':[]}
with open('sim_data/sim_sink_power.txt', 'r') as sim_sink_file:
    for sim_sink_line in sim_sink_file:
        line_data = sim_sink_line.split(' ')
        sim_sink_data['last'].append(int(line_data[0], 16))
        sim_sink_data['data'].append(int(line_data[1], 16))

# Implement the algorithm
sim_expected_data = []
for ix in range(len(sim_source_data['data']['i'])):
    sim_expected_data.append(sim_source_data['data']['i'][ix]**2 + sim_source_data['data']['q'][ix]**2)

if sim_expected_data == sim_sink_data['data']:
    print('PASS: power simulation data is correct')
else:
    print('ERROR: power simulation data is incorrect')
    print('    * Expected: {}'.format(sim_expected_data))
    print('    * Received: {}'.format(sim_sink_data['data']))
    sys.exit(1)
```

We can tell FINS to add this script to the simulation process by adding it to the **fins.json** file. Modify your **fins.json** file to add the following code inside the `filesets` top-level key. Remember to use a comma after the closing curly brace (`}`) of `sim`!

```json
    "scripts":{
      "postsim":[
        { "path":"scripts/verify_sim.py" }
      ]
    }
```

The next step is to regenerate the scripts and re-run the ModelSim (Quartus) and Vivado simulations.

> NOTE: In these commands, we are running the simulations in "batch" mode. This means that the GUIs will not launch and the results will be located in the **log/ip_simulate.log** file.

```bash
$ make clean
$ fins -b vivado fins.json
$ make sim
$ make clean
$ fins -b quartus fins.json
$ make sim
```

Verify all the commands completed without error, and check the log files after each `make sim` to ensure the Python script passed!

## Solution

The solution files for this tutorial are located in the **tutorials/power_converter** directory of the FINS repository.

**[RETURN TO TOP LEVEL README](../README.md)**
