# Manual FINS Testing

**[RETURN TO TOP LEVEL README](../README.md)**

These procedures validate that FINS can parse and generate Nodes, Applications,
and Systems with the supported vendor backends. For focused shell-test scopes
and CI artifact details, see
[CI Test Scopes and Failure Logs](../README.md#ci-test-scopes-and-failure-logs).

Append `UseGui=1` to a simulation target to run it in GUI mode.

## Testing FINS Nodes

Test that FINS can parse Node JSON, generate an IP and testbench, and simulate
the result. The `node` shell-test scope exercises both the packaged-IP fixture
under `test/node/` and the direct-simulation primitive fixture under
`test/primitive/`.

### Vivado

```bash
# Enter the test IP directory:
cd fins/test/node/
# Generate the Vivado backend:
fins -b vivado fins.json
# Build the core:
make
# Run the simulation in command-line mode:
make sim
# Run the simulation using the GUI:
make sim UseGui=1
```

### Primitive Nodes

The normal backend test scope runs the primitive fixture in batch mode with a
real simulator and verifies the generated simulation log reports success:

```bash
./test/test_backend.sh vivado node
./test/test_backend.sh quartus node
```

To exercise that fixture directly, substitute `fins/test/primitive/` for the
Node directory in the commands above. Primitive Nodes compile their authored
HDL and testbench directly; they do not create a packaged-IP project.

### AXI-Stream File Helpers

The vendor-independent AXI file scope generates the Octave/MATLAB read and
write helpers and runs their data and metadata regression matrix in Octave.
The metadata cases cover signed, unsigned, real, complex, mixed, wide TUSER,
and declaration-order packing:

```bash
./test/test_core.sh axis-files
```

### Quartus

```bash
# Enter the test IP directory:
cd fins/test/node/
# Generate the Quartus backend:
fins -b quartus fins.json
# Build the core:
make
# Run the simulation in command-line mode:
make sim
# Run the simulation using the GUI:
make sim UseGui=1
```

## Testing FINS Applications

Test that FINS can parse Application JSON, instantiate Nodes, and generate and
simulate an Application testbench.

### Vivado

```bash
# Enter the test Application directory:
cd fins/test/application/
# Generate the Vivado backend:
fins -b vivado application_test.json
# Build the Application:
make
# Run the simulation in command-line mode:
make sim
# Run the simulation using the GUI:
make sim UseGui=1
```

### Quartus

```bash
# Enter the test Application directory:
cd fins/test/application/
# Generate the Quartus backend:
fins -b quartus application_test.json
# Build the Application:
make
# Run the simulation in command-line mode:
make sim
# Run the simulation using the GUI:
make sim UseGui=1
```

## Testing FINS Systems

Test that FINS can parse a System JSON file and generate its core outputs.

### Vivado

> NOTE: This test requires the `avnet.com:zedboard:part0:1.5` board part.

```bash
# Install the ZedBoard board part if it is not already installed:
git clone https://github.com/Avnet/bdf.git
sudo mv bdf/zed* /opt/Xilinx/Vivado/2022.2/data/xhub/boards/XilinxBoardStore/boards/Avnet/
# Test the FINS System:
cd fins/test/system/
make
fins vivado_system_test.json
```

### Quartus

```bash
cd fins/test/system/
make
fins quartus_system_test.json
```

## Additional Testing

Additional FINS Nodes and an Application live in `tutorials/` and can be useful
for testing.

**[RETURN TO TOP LEVEL README](../README.md)**
