# FINS on a Zedboard

This guide explains how to install and run FINS on a Zedboard.

## Prerequisites

* You must have finished the `power_converter` tutorial
* Xilinx Vivado 2019.2
* Xilinx Petalinux 2019.2
* FINS v0.16

This guide assumes that you have a directory structure as listed below.

* ./pl/ - Just an empty folder at this time
* ./ps/ - A folder with the contents below
    * ./software/ - A folder with the contents below
        * ./fins-sw/ - The receipe and source code for FINS software
        * ./fins-sw-devmem/ - The receipe and source code for FINS software devmem implementation

## Programmable Logic

Navigate to a directory to perform your development, create the **ps** and **pl** folders, and open Vivado.

> NOTE: Make sure you have sourced the Xilinx Vivado settings64.sh script!

```bash
cd pl
vivado &
```

Follow the steps below to create a project and instantiate your `power_converter` FPGA IP.

1. Click **File>Project>New...**
2. Click **Next** in the "Create a New Vivado Project" screen
3. In the "Project Name" screen:
    1. Type "fins_zedboard" for "Project name"
    2. Make sure "Create project subdirectory" is checked
    3. Click **Next**
4. Select "RTL Project" in the "Project Type" screen
5. Leave everything as default on the "Add Sources" screen and click **Next**
6. Leave everything as default on the "Add Constraints" screen and click **Next**
7. In the "Default Part" screen:
    1. Navigate to the "Boards" tab
    2. Select "ZedBoard Zynq Evaluation and Development kit"
    3. Click **Next**
8. Click **Finish** in the final screen
9. Once the project opens, click **Create Block Design** in the "Flow Navigator" panel on the left
10. In the "Create Block Design", enter "system_top" for the "Design name" and click **OK**
11. In the "Diagram" panel on the top right:
    1. Click the **+** button, type "Zynq7 Processing System", and double-click the item to add it to the block design
    2. Click the **Run Block Automation** button at the top of the diagram and click **OK** in the dialog that appears, leaving all options their default
12. Click **IP Catalog** from the "Flow Navigator" panel on the left
13. In the "IP Catalog" tab, right-click on any folder that is listed and click **Add Repository...**
14. In the "Repositories" dialog, browse to the location of your `power_converter` IP from the previous Tutorial and click **Select**
15. The "Add Repository" dialog should appear and notify that "1 repository was added to the project", click **OK** in this dialog
16. Navigate to the "Diagram" tab in the top right panel
17. In the "Diagram" tab,
    1. Click the **+** button, type "power_converter" and double-click this entry to add it to the diagram
    2. Click the **Run Block Automation** button at the top of the diagram and click **OK** in the dialog that appears, leaving all options their default
    3. Connect the `s_axis_iq_aclk` and `m_axis_power_aclk` ports of the **power_converter** to the `FCLK_CLK0` port of the **processing_system7_0**
    4. Connect the `s_axis_iq_aresetn` and `m_axis_power_aresetn` ports of the **power_converter** to the `FCLK_RESET0_N` port of the **processing_system7_0**
    5. Click the **Validate Design** button at the top of the "Diagram" tab (it looks like a check mark) and click **OK** when there is a dialog with warnings
    6. Save the block design
18. In the "Sources" tab (top-left panel), right click `system_top`, click **Create HDL Wrapper**, and then click **OK** in the "Create HDL Wrapper", leaving options their default
19. Click the **Generate Bitstream** button in the "Flow Navigator", click **Yes** in the dialog to continue, and then click **OK** in the "Launch Runs" dialog
20. Click **File>Export>Export Hardware** to launch the dialog:
    1. Check "Include bitstream"
    2. Click **OK**
21. When the bitstream generation completes, close Vivado.

Create a new file in the **./pl/** directory called **nodeset.json** with the contents below.

```json
{
    "name":"fins_zedboard",
    "base_offset":0,
    "nodes":[
        {
            "fins_path":"/home/rhuser/Documents/power_converter/gen/core/power_converter.json",
            "module_name":"power_converter_0",
            "interface_name":"S_AXI",
            "properties_offset":"fins_zedboard/fins_zedboard.srcs/sources_1/bd/system_top/system_top.bd"
        }
    ]
}
```

Run the `fins` command on the file like the following.

```bash
fins nodeset.json
```

A file will get generated in **./gen/core/** which you will use in the following step.

## Processing System

```bash
cd ps
petalinux-create -t project --template zynq --name fins_zedboard
cd fins_zedboard
petalinux-config --get-hw-description=../../pl/fins_zedboard/
```

For Petalinux 2019.2, when the Menuconfig appears from the command above:

1. Navigate to **Image Packaging Configuration>Root filesystem type>SD card**. Select this option, save the configuration.
2. Exit Menuconfig


```bash
cd ../
# Copy the software to the Petalinux user layer
cp -r software/fins-sw        fins_zedboard/project-spec/meta-user/recipes-apps/
cp -r software/fins-sw-devmem fins_zedboard/project-spec/meta-user/recipes-apps/
# Create a location for the fins-json recipe and copy our nodeset
mkdir -p fins_zedboard/project-spec/meta-user/recipes-apps/fins-json/files/
cp ../pl/gen/core/nodeset.json fins_zedboard/project-spec/meta-user/recipes-apps/fins-json/files/nodeset.json
# Add custom software elements + nice-to-have linux packages to PetaLinux's Yocto IMAGE_INSTALL
echo 'IMAGE_INSTALL_append = " fins-sw-devmem devmem2 vim"' >> fins_zedboard/build/conf/local.conf
```

Create a new file **fins_zedboard/project-spec/meta-user/recipes-apps/fins-json/fins-json.bb** with the contents below.

```
DESCRIPTION = "FINS JSON Description file"
LICENSE = "CLOSED"

RPROVIDES_${PN} = "fins-json"

SRC_URI = "file://nodeset.json"
S = "${WORKDIR}"

FILES_${PN} += "${sysconfdir}/nodeset.json"

do_install() {
    install -d ${D}/${sysconfdir}
    install -d ${D}/${sysconfdir}/fins
    install -m 0644 ${S}/nodeset.json ${D}${sysconfdir}/fins/nodeset.json
}
```

Build and package the project

```bash
# Build the project
cd fins_zedboard
petalinux-build
cd images/linux/
petalinux-package --boot --format BIN --fsbl --fpga system.bit --u-boot --force
cd ../../../../
```

Insert a properly formatted bootable SD card. You should see the **root** and **boot** partitions get mounted. Copy BOOT.BIN, image.ub, boot.scr to BOOT partition of SD card with the commands below. The image.ub file will have a device tree and kernel image files.

```bash
rm -rf /run/media/$USER/boot/*
cp ps/petalinux_vita49dot2_demo/images/linux/{BOOT.BIN,image.ub,boot.scr} /run/media/$USER/boot/
```

Extract the **rootfs.tar.gz** file system to the rootfs partition of SD card with the commands below.

```bash
sudo rm -rf /run/media/$USER/root/*
sudo tar xvf ps/petalinux_vita49dot2_demo/images/linux/rootfs.tar.gz -C /run/media/$USER/root/
```

Synchronize the filesystem to avoid corruption with the command:

```bash
sync; sync
```

Eject the SD card safely with the Disks utility.

## Testing on the Zedboard

Insert your SD card into the Zedboard, connnect a USB cable to the UART port, and power on the Zedboard.

Use the `screen` utility to view the serial console.

```bash
sudo screen /dev/ttyACM0 115200
```

In the serial console, execute the following command.

```bash
fins-poke
```

Use the `fins-poke --help` menu to figure out how to set the `gain` property.


