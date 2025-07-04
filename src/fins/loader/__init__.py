#
# Copyright (C) 2019 Geon Technologies, LLC
#
# This file is part of FINS.
#
# FINS is free software: you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# FINS is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
# more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.
#

import os
import sys
import math
import logging
import json
import re
import xml.etree.ElementTree as ET

from fins.utils import SchemaType


# This logger will inherit log-level and settings from main.py
LOGGER = logging.getLogger('fins.loader')


__all__ = (
    'load_fins_data'
)

NODE_SCHEMA_FILENAME = os.path.dirname(os.path.abspath(__file__)) + '/node.json'
APPLICATION_SCHEMA_FILENAME = os.path.dirname(os.path.abspath(__file__)) + '/application.json'
SYSTEM_SCHEMA_FILENAME = os.path.dirname(os.path.abspath(__file__)) + '/system.json'

SCHEMA_FILENAME = {
    SchemaType.NODE:        NODE_SCHEMA_FILENAME,
    SchemaType.APPLICATION: APPLICATION_SCHEMA_FILENAME,
    SchemaType.SYSTEM:      SYSTEM_SCHEMA_FILENAME
}

SCHEMA_TYPES = ['int', 'float', 'bool', 'str', 'list', 'dict']
SCHEMA_LIST_TYPES = ['int', 'float', 'bool', 'str', 'dict']
SCHEMA_KEYS = ['is_required', 'types', 'list_types', 'fields']
PROPERTY_TYPES = [
    'read-only-constant',
    'read-only-data',
    'read-only-external',
    'read-only-memmap',
    'write-only-external',
    'write-only-memmap',
    'read-write-internal',
    'read-write-data',
    'read-write-external',
    'read-write-memmap'
]
PORT_DIRECTIONS = ['in', 'out']
PORT_HDL_DIRECTIONS = ['in', 'out']
QUARTUS_DESIGN_FILE_TYPES = ['dat', 'fli_library', 'hex', 'mif', 'other', 'pli_library', 'system_verilog', 'system_verilog_encrypt', 'system_verilog_include', 'verilog', 'verilog_encrypt', 'verilog_include', 'vhdl', 'vhdl_encrypt', 'vpi_library']
SCRIPT_FILE_TYPES = ['matlab', 'octave', 'python', 'python3', 'tcl', 'cmdline']
CONSTRAINT_FILE_TYPES = ['xdc', 'sdc']
VENDOR_SCRIPT_FILE_TYPES = ['tcl']
# Regular expression strings used with re.search() on port names
# NOTE: Use re.IGNORECASE
INTERFACE_PORT_INFERENCE = {
    'reset':[
        { 'pattern':r'reset',        'regex':False,'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'\w+_reset',    'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'reset_\w+',    'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'resetin',      'regex':False,'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'\w+_resetin',  'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'resetin_\w+',  'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'resetn',       'regex':False,'properties':{'signal':'reset_n','polarity':'active_low' }},
        { 'pattern':r'\w+_resetn',   'regex':True, 'properties':{'signal':'reset_n','polarity':'active_low' }},
        { 'pattern':r'resetn_\w+',   'regex':True, 'properties':{'signal':'reset_n','polarity':'active_low' }},
        { 'pattern':r'rst',          'regex':False,'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'\w+_rst',      'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'rst_\w+',      'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'rstin',        'regex':False,'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'\w+_rstin',    'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'rstin_\w+',    'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'aresetn',      'regex':False,'properties':{'signal':'reset_n','polarity':'active_low' }},
        { 'pattern':r'\w+_aresetn',  'regex':True, 'properties':{'signal':'reset_n','polarity':'active_low' }},
        { 'pattern':r'aresetn_\w+',  'regex':True, 'properties':{'signal':'reset_n','polarity':'active_low' }}
    ],
    'clock':[
        { 'pattern':r'clock',        'regex':False,'properties':{'signal':'clk'}},
        { 'pattern':r'\w+_clock',    'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'clock_\w+',    'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'clk',          'regex':False,'properties':{'signal':'clk'}},
        { 'pattern':r'\w+_clk',      'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'clk_\w+',      'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'clkin',        'regex':False,'properties':{'signal':'clk'}},
        { 'pattern':r'\w+_clkin',    'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'clkin_\w+',    'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'aclk',         'regex':False,'properties':{'signal':'clk'}},
        { 'pattern':r'\w+_aclk',     'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'aclk_\w+',     'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'aclkin',       'regex':False,'properties':{'signal':'clk'}},
        { 'pattern':r'\w+_aclkin',   'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'aclkin_\w+',   'regex':True, 'properties':{'signal':'clk'}}
    ],
    'axi4stream':[
        { 'pattern':r's\d*_axis_aclk|s\d*_axis_\w*_aclk',      'regex':True,'properties':{'mode':'slave',  'signal':'clk'    }},
        { 'pattern':r's\d*_axis_aresetn|s\d*_axis_\w*_aresetn','regex':True,'properties':{'mode':'slave',  'signal':'reset_n'}},
        { 'pattern':r's\d*_axis_tdata|s\d*_axis_\w*_tdata',    'regex':True,'properties':{'mode':'slave',  'signal':'tdata'  }},
        { 'pattern':r's\d*_axis_tvalid|s\d*_axis_\w*_tvalid',  'regex':True,'properties':{'mode':'slave',  'signal':'tvalid' }},
        { 'pattern':r's\d*_axis_tready|s\d*_axis_\w*_tready',  'regex':True,'properties':{'mode':'slave',  'signal':'tready' }},
        { 'pattern':r's\d*_axis_tstrb|s\d*_axis_\w*_tstrb',    'regex':True,'properties':{'mode':'slave',  'signal':'tstrb'  }},
        { 'pattern':r's\d*_axis_tkeep|s\d*_axis_\w*_tkeep',    'regex':True,'properties':{'mode':'slave',  'signal':'tkeep'  }},
        { 'pattern':r's\d*_axis_tlast|s\d*_axis_\w*_tlast',    'regex':True,'properties':{'mode':'slave',  'signal':'tlast'  }},
        { 'pattern':r's\d*_axis_tid|s\d*_axis_\w*_tid',        'regex':True,'properties':{'mode':'slave',  'signal':'tid'    }},
        { 'pattern':r's\d*_axis_tdest|s\d*_axis_\w*_tdest',    'regex':True,'properties':{'mode':'slave',  'signal':'tdest'  }},
        { 'pattern':r's\d*_axis_tuser|s\d*_axis_\w*_tuser',    'regex':True,'properties':{'mode':'slave',  'signal':'tuser'  }},
        { 'pattern':r'm\d*_axis_aclk|m\d*_axis_\w*_aclk',      'regex':True,'properties':{'mode':'master', 'signal':'clk'    }},
        { 'pattern':r'm\d*_axis_aresetn|m\d*_axis_\w*_aresetn','regex':True,'properties':{'mode':'master', 'signal':'reset_n'}},
        { 'pattern':r'm\d*_axis_tdata|m\d*_axis_\w*_tdata',    'regex':True,'properties':{'mode':'master', 'signal':'tdata'  }},
        { 'pattern':r'm\d*_axis_tvalid|m\d*_axis_\w*_tvalid',  'regex':True,'properties':{'mode':'master', 'signal':'tvalid' }},
        { 'pattern':r'm\d*_axis_tready|m\d*_axis_\w*_tready',  'regex':True,'properties':{'mode':'master', 'signal':'tready' }},
        { 'pattern':r'm\d*_axis_tstrb|m\d*_axis_\w*_tstrb',    'regex':True,'properties':{'mode':'master', 'signal':'tstrb'  }},
        { 'pattern':r'm\d*_axis_tkeep|m\d*_axis_\w*_tkeep',    'regex':True,'properties':{'mode':'master', 'signal':'tkeep'  }},
        { 'pattern':r'm\d*_axis_tlast|m\d*_axis_\w*_tlast',    'regex':True,'properties':{'mode':'master', 'signal':'tlast'  }},
        { 'pattern':r'm\d*_axis_tid|m\d*_axis_\w*_tid',        'regex':True,'properties':{'mode':'master', 'signal':'tid'    }},
        { 'pattern':r'm\d*_axis_tdest|m\d*_axis_\w*_tdest',    'regex':True,'properties':{'mode':'master', 'signal':'tdest'  }},
        { 'pattern':r'm\d*_axis_tuser|m\d*_axis_\w*_tuser',    'regex':True,'properties':{'mode':'master', 'signal':'tuser'  }}
    ],
    'axi4lite':[
        { 'pattern':r's\d*_axi_aclk|s\d*_axi_\w+_aclk',        'regex':True,'properties':{'mode':'slave',  'signal':'clk'     }},
        { 'pattern':r's\d*_axi_aresetn|s\d*_axi_\w+_aresetn',  'regex':True,'properties':{'mode':'slave',  'signal':'reset_n' }},
        { 'pattern':r's\d*_axi_awid|s\d*_axi_\w+_awid',        'regex':True,'properties':{'mode':'slave',  'signal':'awid'    }},
        { 'pattern':r's\d*_axi_awaddr|s\d*_axi_\w+_awaddr',    'regex':True,'properties':{'mode':'slave',  'signal':'awaddr'  }},
        { 'pattern':r's\d*_axi_awlen|s\d*_axi_\w+_awlen',      'regex':True,'properties':{'mode':'slave',  'signal':'awlen'   }},
        { 'pattern':r's\d*_axi_awsize|s\d*_axi_\w+_awsize',    'regex':True,'properties':{'mode':'slave',  'signal':'awsize'  }},
        { 'pattern':r's\d*_axi_awburst|s\d*_axi_\w+_awburst',  'regex':True,'properties':{'mode':'slave',  'signal':'awburst' }},
        { 'pattern':r's\d*_axi_awlock|s\d*_axi_\w+_awlock',    'regex':True,'properties':{'mode':'slave',  'signal':'awlock'  }},
        { 'pattern':r's\d*_axi_awcache|s\d*_axi_\w+_awcache',  'regex':True,'properties':{'mode':'slave',  'signal':'awcache' }},
        { 'pattern':r's\d*_axi_awprot|s\d*_axi_\w+_awprot',    'regex':True,'properties':{'mode':'slave',  'signal':'awprot'  }},
        { 'pattern':r's\d*_axi_awqos|s\d*_axi_\w+_awqos',      'regex':True,'properties':{'mode':'slave',  'signal':'awqos'   }},
        { 'pattern':r's\d*_axi_awregion|s\d*_axi_\w+_awregion','regex':True,'properties':{'mode':'slave',  'signal':'awregion'}},
        { 'pattern':r's\d*_axi_awuser|s\d*_axi_\w+_awuser',    'regex':True,'properties':{'mode':'slave',  'signal':'awuser'  }},
        { 'pattern':r's\d*_axi_awvalid|s\d*_axi_\w+_awvalid',  'regex':True,'properties':{'mode':'slave',  'signal':'awvalid' }},
        { 'pattern':r's\d*_axi_awready|s\d*_axi_\w+_awready',  'regex':True,'properties':{'mode':'slave',  'signal':'awready' }},
        { 'pattern':r's\d*_axi_wid|s\d*_axi_\w+_wid',          'regex':True,'properties':{'mode':'slave',  'signal':'wid'     }},
        { 'pattern':r's\d*_axi_wdata|s\d*_axi_\w+_wdata',      'regex':True,'properties':{'mode':'slave',  'signal':'wdata'   }},
        { 'pattern':r's\d*_axi_wstrb|s\d*_axi_\w+_wstrb',      'regex':True,'properties':{'mode':'slave',  'signal':'wstrb'   }},
        { 'pattern':r's\d*_axi_wlast|s\d*_axi_\w+_wlast',      'regex':True,'properties':{'mode':'slave',  'signal':'wlast'   }},
        { 'pattern':r's\d*_axi_wuser|s\d*_axi_\w+_wuser',      'regex':True,'properties':{'mode':'slave',  'signal':'wuser'   }},
        { 'pattern':r's\d*_axi_wvalid|s\d*_axi_\w+_wvalid',    'regex':True,'properties':{'mode':'slave',  'signal':'wvalid'  }},
        { 'pattern':r's\d*_axi_wready|s\d*_axi_\w+_wready',    'regex':True,'properties':{'mode':'slave',  'signal':'wready'  }},
        { 'pattern':r's\d*_axi_bid|s\d*_axi_\w+_bid',          'regex':True,'properties':{'mode':'slave',  'signal':'bid'     }},
        { 'pattern':r's\d*_axi_bresp|s\d*_axi_\w+_bresp',      'regex':True,'properties':{'mode':'slave',  'signal':'bresp'   }},
        { 'pattern':r's\d*_axi_buser|s\d*_axi_\w+_buser',      'regex':True,'properties':{'mode':'slave',  'signal':'buser'   }},
        { 'pattern':r's\d*_axi_bvalid|s\d*_axi_\w+_bvalid',    'regex':True,'properties':{'mode':'slave',  'signal':'bvalid'  }},
        { 'pattern':r's\d*_axi_bready|s\d*_axi_\w+_bready',    'regex':True,'properties':{'mode':'slave',  'signal':'bready'  }},
        { 'pattern':r's\d*_axi_arid|s\d*_axi_\w+_arid',        'regex':True,'properties':{'mode':'slave',  'signal':'arid'    }},
        { 'pattern':r's\d*_axi_araddr|s\d*_axi_\w+_araddr',    'regex':True,'properties':{'mode':'slave',  'signal':'araddr'  }},
        { 'pattern':r's\d*_axi_arlen|s\d*_axi_\w+_arlen',      'regex':True,'properties':{'mode':'slave',  'signal':'arlen'   }},
        { 'pattern':r's\d*_axi_arsize|s\d*_axi_\w+_arsize',    'regex':True,'properties':{'mode':'slave',  'signal':'arsize'  }},
        { 'pattern':r's\d*_axi_arburst|s\d*_axi_\w+_arburst',  'regex':True,'properties':{'mode':'slave',  'signal':'arburst' }},
        { 'pattern':r's\d*_axi_arlock|s\d*_axi_\w+_arlock',    'regex':True,'properties':{'mode':'slave',  'signal':'arlock'  }},
        { 'pattern':r's\d*_axi_arcache|s\d*_axi_\w+_arcache',  'regex':True,'properties':{'mode':'slave',  'signal':'arcache' }},
        { 'pattern':r's\d*_axi_arprot|s\d*_axi_\w+_arprot',    'regex':True,'properties':{'mode':'slave',  'signal':'arprot'  }},
        { 'pattern':r's\d*_axi_arqos|s\d*_axi_\w+_arqos',      'regex':True,'properties':{'mode':'slave',  'signal':'arqos'   }},
        { 'pattern':r's\d*_axi_arregion|s\d*_axi_\w+_arregion','regex':True,'properties':{'mode':'slave',  'signal':'arregion'}},
        { 'pattern':r's\d*_axi_aruser|s\d*_axi_\w+_aruser',    'regex':True,'properties':{'mode':'slave',  'signal':'aruser'  }},
        { 'pattern':r's\d*_axi_arvalid|s\d*_axi_\w+_arvalid',  'regex':True,'properties':{'mode':'slave',  'signal':'arvalid' }},
        { 'pattern':r's\d*_axi_arready|s\d*_axi_\w+_arready',  'regex':True,'properties':{'mode':'slave',  'signal':'arready' }},
        { 'pattern':r's\d*_axi_rid|s\d*_axi_\w+_rid',          'regex':True,'properties':{'mode':'slave',  'signal':'rid'     }},
        { 'pattern':r's\d*_axi_rdata|s\d*_axi_\w+_rdata',      'regex':True,'properties':{'mode':'slave',  'signal':'rdata'   }},
        { 'pattern':r's\d*_axi_rresp|s\d*_axi_\w+_rresp',      'regex':True,'properties':{'mode':'slave',  'signal':'rresp'   }},
        { 'pattern':r's\d*_axi_ruser|s\d*_axi_\w+_ruser',      'regex':True,'properties':{'mode':'slave',  'signal':'ruser'   }},
        { 'pattern':r's\d*_axi_rvalid|s\d*_axi_\w+_rvalid',    'regex':True,'properties':{'mode':'slave',  'signal':'rvalid'  }},
        { 'pattern':r's\d*_axi_rready|s\d*_axi_\w+_rready',    'regex':True,'properties':{'mode':'slave',  'signal':'rready'  }},
        { 'pattern':r'm\d*_axi_aclk|m\d*_axi_\w+_aclk',        'regex':True,'properties':{'mode':'master', 'signal':'clk'     }},
        { 'pattern':r'm\d*_axi_aresetn|m\d*_axi_\w+_aresetn',  'regex':True,'properties':{'mode':'master', 'signal':'reset_n' }},
        { 'pattern':r'm\d*_axi_awid|m\d*_axi_\w+_awid',        'regex':True,'properties':{'mode':'master', 'signal':'awid'    }},
        { 'pattern':r'm\d*_axi_awaddr|m\d*_axi_\w+_awaddr',    'regex':True,'properties':{'mode':'master', 'signal':'awaddr'  }},
        { 'pattern':r'm\d*_axi_awlen|m\d*_axi_\w+_awlen',      'regex':True,'properties':{'mode':'master', 'signal':'awlen'   }},
        { 'pattern':r'm\d*_axi_awsize|m\d*_axi_\w+_awsize',    'regex':True,'properties':{'mode':'master', 'signal':'awsize'  }},
        { 'pattern':r'm\d*_axi_awburst|m\d*_axi_\w+_awburst',  'regex':True,'properties':{'mode':'master', 'signal':'awburst' }},
        { 'pattern':r'm\d*_axi_awlock|m\d*_axi_\w+_awlock',    'regex':True,'properties':{'mode':'master', 'signal':'awlock'  }},
        { 'pattern':r'm\d*_axi_awcache|m\d*_axi_\w+_awcache',  'regex':True,'properties':{'mode':'master', 'signal':'awcache' }},
        { 'pattern':r'm\d*_axi_awprot|m\d*_axi_\w+_awprot',    'regex':True,'properties':{'mode':'master', 'signal':'awprot'  }},
        { 'pattern':r'm\d*_axi_awqos|m\d*_axi_\w+_awqos',      'regex':True,'properties':{'mode':'master', 'signal':'awqos'   }},
        { 'pattern':r'm\d*_axi_awregion|m\d*_axi_\w+_awregion','regex':True,'properties':{'mode':'master', 'signal':'awregion'}},
        { 'pattern':r'm\d*_axi_awuser|m\d*_axi_\w+_awuser',    'regex':True,'properties':{'mode':'master', 'signal':'awuser'  }},
        { 'pattern':r'm\d*_axi_awvalid|m\d*_axi_\w+_awvalid',  'regex':True,'properties':{'mode':'master', 'signal':'awvalid' }},
        { 'pattern':r'm\d*_axi_awready|m\d*_axi_\w+_awready',  'regex':True,'properties':{'mode':'master', 'signal':'awready' }},
        { 'pattern':r'm\d*_axi_wid|m\d*_axi_\w+_wid',          'regex':True,'properties':{'mode':'master', 'signal':'wid'     }},
        { 'pattern':r'm\d*_axi_wdata|m\d*_axi_\w+_wdata',      'regex':True,'properties':{'mode':'master', 'signal':'wdata'   }},
        { 'pattern':r'm\d*_axi_wstrb|m\d*_axi_\w+_wstrb',      'regex':True,'properties':{'mode':'master', 'signal':'wstrb'   }},
        { 'pattern':r'm\d*_axi_wlast|m\d*_axi_\w+_wlast',      'regex':True,'properties':{'mode':'master', 'signal':'wlast'   }},
        { 'pattern':r'm\d*_axi_wuser|m\d*_axi_\w+_wuser',      'regex':True,'properties':{'mode':'master', 'signal':'wuser'   }},
        { 'pattern':r'm\d*_axi_wvalid|m\d*_axi_\w+_wvalid',    'regex':True,'properties':{'mode':'master', 'signal':'wvalid'  }},
        { 'pattern':r'm\d*_axi_wready|m\d*_axi_\w+_wready',    'regex':True,'properties':{'mode':'master', 'signal':'wready'  }},
        { 'pattern':r'm\d*_axi_bid|m\d*_axi_\w+_bid',          'regex':True,'properties':{'mode':'master', 'signal':'bid'     }},
        { 'pattern':r'm\d*_axi_bresp|m\d*_axi_\w+_bresp',      'regex':True,'properties':{'mode':'master', 'signal':'bresp'   }},
        { 'pattern':r'm\d*_axi_buser|m\d*_axi_\w+_buser',      'regex':True,'properties':{'mode':'master', 'signal':'buser'   }},
        { 'pattern':r'm\d*_axi_bvalid|m\d*_axi_\w+_bvalid',    'regex':True,'properties':{'mode':'master', 'signal':'bvalid'  }},
        { 'pattern':r'm\d*_axi_bready|m\d*_axi_\w+_bready',    'regex':True,'properties':{'mode':'master', 'signal':'bready'  }},
        { 'pattern':r'm\d*_axi_arid|m\d*_axi_\w+_arid',        'regex':True,'properties':{'mode':'master', 'signal':'arid'    }},
        { 'pattern':r'm\d*_axi_araddr|m\d*_axi_\w+_araddr',    'regex':True,'properties':{'mode':'master', 'signal':'araddr'  }},
        { 'pattern':r'm\d*_axi_arlen|m\d*_axi_\w+_arlen',      'regex':True,'properties':{'mode':'master', 'signal':'arlen'   }},
        { 'pattern':r'm\d*_axi_arsize|m\d*_axi_\w+_arsize',    'regex':True,'properties':{'mode':'master', 'signal':'arsize'  }},
        { 'pattern':r'm\d*_axi_arburst|m\d*_axi_\w+_arburst',  'regex':True,'properties':{'mode':'master', 'signal':'arburst' }},
        { 'pattern':r'm\d*_axi_arlock|m\d*_axi_\w+_arlock',    'regex':True,'properties':{'mode':'master', 'signal':'arlock'  }},
        { 'pattern':r'm\d*_axi_arcache|m\d*_axi_\w+_arcache',  'regex':True,'properties':{'mode':'master', 'signal':'arcache' }},
        { 'pattern':r'm\d*_axi_arprot|m\d*_axi_\w+_arprot',    'regex':True,'properties':{'mode':'master', 'signal':'arprot'  }},
        { 'pattern':r'm\d*_axi_arqos|m\d*_axi_\w+_arqos',      'regex':True,'properties':{'mode':'master', 'signal':'arqos'   }},
        { 'pattern':r'm\d*_axi_arregion|m\d*_axi_\w+_arregion','regex':True,'properties':{'mode':'master', 'signal':'arregion'}},
        { 'pattern':r'm\d*_axi_aruser|m\d*_axi_\w+_aruser',    'regex':True,'properties':{'mode':'master', 'signal':'aruser'  }},
        { 'pattern':r'm\d*_axi_arvalid|m\d*_axi_\w+_arvalid',  'regex':True,'properties':{'mode':'master', 'signal':'arvalid' }},
        { 'pattern':r'm\d*_axi_arready|m\d*_axi_\w+_arready',  'regex':True,'properties':{'mode':'master', 'signal':'arready' }}, 
        { 'pattern':r'm\d*_axi_rid|m\d*_axi_\w+_rid',          'regex':True,'properties':{'mode':'master', 'signal':'rid'     }},
        { 'pattern':r'm\d*_axi_rdata|m\d*_axi_\w+_rdata',      'regex':True,'properties':{'mode':'master', 'signal':'rdata'   }},
        { 'pattern':r'm\d*_axi_rresp|m\d*_axi_\w+_rresp',      'regex':True,'properties':{'mode':'master', 'signal':'rresp'   }},
        { 'pattern':r'm\d*_axi_ruser|m\d*_axi_\w+_ruser',      'regex':True,'properties':{'mode':'master', 'signal':'ruser'   }},
        { 'pattern':r'm\d*_axi_rvalid|m\d*_axi_\w+_rvalid',    'regex':True,'properties':{'mode':'master', 'signal':'rvalid'  }},
        { 'pattern':r'm\d*_axi_rready|m\d*_axi_\w+_rready',    'regex':True,'properties':{'mode':'master', 'signal':'rready'  }}
    ],
    'avalon_streaming':[
        { 'pattern':r'asi\w*_clk|asi\w*_clock','regex':True,'properties':{'mode':'sink',   'signal':'clk'          }},
        { 'pattern':r'asi\w*_rst|asi\w*_reset','regex':True,'properties':{'mode':'sink',   'signal':'reset'        }},
        { 'pattern':r'asi\w*_channel',         'regex':True,'properties':{'mode':'sink',   'signal':'channel'      }},
        { 'pattern':r'asi\w*_data',            'regex':True,'properties':{'mode':'sink',   'signal':'data'         }},
        { 'pattern':r'asi\w*_error',           'regex':True,'properties':{'mode':'sink',   'signal':'error'        }},
        { 'pattern':r'asi\w*_ready',           'regex':True,'properties':{'mode':'sink',   'signal':'ready'        }},
        { 'pattern':r'asi\w*_valid',           'regex':True,'properties':{'mode':'sink',   'signal':'valid'        }},
        { 'pattern':r'asi\w*_empty',           'regex':True,'properties':{'mode':'sink',   'signal':'empty'        }},
        { 'pattern':r'asi\w*_endofpacket',     'regex':True,'properties':{'mode':'sink',   'signal':'endofpacket'  }},
        { 'pattern':r'asi\w*_startofpacket',   'regex':True,'properties':{'mode':'sink',   'signal':'startofpacket'}},
        { 'pattern':r'aso\w*_clk|aso\w*_clock','regex':True,'properties':{'mode':'source', 'signal':'clk'          }},
        { 'pattern':r'aso\w*_rst|aso\w*_reset','regex':True,'properties':{'mode':'source', 'signal':'reset'        }},
        { 'pattern':r'aso\w*_channel',         'regex':True,'properties':{'mode':'source', 'signal':'channel'      }},
        { 'pattern':r'aso\w*_data',            'regex':True,'properties':{'mode':'source', 'signal':'data'         }},
        { 'pattern':r'aso\w*_error',           'regex':True,'properties':{'mode':'source', 'signal':'error'        }},
        { 'pattern':r'aso\w*_ready',           'regex':True,'properties':{'mode':'source', 'signal':'ready'        }},
        { 'pattern':r'aso\w*_valid',           'regex':True,'properties':{'mode':'source', 'signal':'valid'        }},
        { 'pattern':r'aso\w*_empty',           'regex':True,'properties':{'mode':'source', 'signal':'empty'        }},
        { 'pattern':r'aso\w*_endofpacket',     'regex':True,'properties':{'mode':'source', 'signal':'endofpacket'  }},
        { 'pattern':r'aso\w*_startofpacket',   'regex':True,'properties':{'mode':'source', 'signal':'startofpacket'}},
    ]
}

################################################################################
# Loader Utility Functions
################################################################################

def load_json_file(filename):
    """Loads data from a JSON file
    """
    # Load JSON
    if os.path.exists(filename):
        with open(filename) as fins_file:
            json_data = json.load(fins_file)
    else:
        LOGGER.error(f'No file {filename} exists')
        sys.exit(1)

    # Return
    return json_data


def get_interface_name(interface_type, hdl_port):
    return get_str_interface_name(interface_type, hdl_port['name'])


def get_str_interface_name(interface_type, name):
    if interface_type == 'reset':
        return name
    elif interface_type == 'clock':
        return name
    elif interface_type == 'axi4stream':
        return name.rpartition('_')[0]
    elif interface_type == 'axi4lite':
        return name.rpartition('_')[0]
    elif interface_type == 'avalon_streaming':
        return name.rpartition('_')[0]
    else:
        LOGGER.error(f'Unsupported interface type {interface_type}')
        sys.exit(1)


def get_interface_mode(interface_type, hdl_port, signal_def):
    if interface_type == 'reset':
        if 'in' in hdl_port['direction']:
            return 'sink'
        else:
            return 'source'
    elif interface_type == 'clock':
        if 'in' in hdl_port['direction']:
            return 'sink'
        else:
            return 'source'
    else:
        return signal_def['properties']['mode']


def get_param_value(params,key_or_value):
    if isinstance(key_or_value, str):
        for param in params:
            if key_or_value.lower() == param['name'].lower():
                return param['value']
        else:
            LOGGER.error(f'{key_or_value} not found in params')
            sys.exit(1)
    else:
        return key_or_value


def convert_parameters_to_literal(fins_data):
    # Get the parameters
    params = []
    if 'params' in fins_data:
        params = fins_data['params']

    # Convert all non-string fields of ports to literals
    if 'ports' in fins_data:
        # Loop through FINS Ports
        if 'ports' in fins_data['ports']:
            for port in fins_data['ports']['ports']:
                # Convert port fields
                for key, value in port.items():
                    # Don't convert string/dictionary typed fields
                    if (key.lower() == 'name') or (key.lower() == 'direction') or (key.lower() == 'data') or (key.lower() == 'metadata'):
                        continue
                    # Convert value
                    port[key] = get_param_value(params, value)

                # Convert data fields
                for key, value in port['data'].items():
                    # Convert value
                    port['data'][key] = get_param_value(params, value)

                # Convert metadata fields
                if 'metadata' in port:
                    for metafield in port['metadata']:
                        for key, value in metafield.items():
                            # Don't convert string typed fields
                            if (key.lower() == 'name'):
                                continue
                            # Convert value
                            metafield[key] = get_param_value(params, value)
        # Loop through FINS Ports HDL
        if 'hdl' in fins_data['ports']:
            for port_hdl in fins_data['ports']['hdl']:
                # Convert port HDL fields
                for key, value in port_hdl.items():
                    # Don't convert string/dictionary typed fields
                    if (key.lower() == 'name') or (key.lower() == 'direction'):
                        continue
                    # Convert value
                    port_hdl[key] = get_param_value(params, value)

    # Convert all non-string fields of properties
    if 'properties' in fins_data:
        # Convert top-level elements
        fins_data['properties']['addr_width'] = get_param_value(params, fins_data['properties']['addr_width'])
        fins_data['properties']['data_width'] = get_param_value(params, fins_data['properties']['data_width'])
        fins_data['properties']['is_addr_byte_indexed'] = get_param_value(params, fins_data['properties']['is_addr_byte_indexed'])
        # Process properties
        for prop in fins_data['properties']['properties']:
            # Iterate through the property dictionary
            for key, value in prop.items():
                # Don't convert string typed fields
                if (key.lower() == 'name'):
                    continue
                if (key.lower() == 'description'):
                    continue
                if (key.lower() == 'type'):
                    continue
                # Convert value
                prop[key] = get_param_value(params, value)

    # Convert all string fields of node to literals
    if 'nodes' in fins_data:
        for node in fins_data['nodes']:
            # Make sure there are params
            if 'params' in node:
                # Loop through parameters of node
                for param_ix, param in enumerate(node['params']):
                    # Get the value of parent parameter
                    parent_value = get_param_value(params, param['parent'])
                    if parent_value is None:
                        LOGGER.error(f'{param["parent"]} of {node["fins_path"]} not found in parent IP')
                        sys.exit(1)
                    # Put the value into the node
                    node['params'][param_ix]['value'] = parent_value
                    node['params'][param_ix]['parent_ip'] = fins_data['name']

    # Convert all string fields of IP to literals
    if 'ip' in fins_data:
        for ip in fins_data['ip']:
            # Make sure there are params
            if 'params' in ip:
                # Loop through parameters of IP
                for param_ix, param in enumerate(ip['params']):
                    # Get the value of parent parameter
                    parent_value = get_param_value(params, param['parent'])
                    if parent_value is None:
                        LOGGER.error(f'{param["parent"]} of {ip["fins_path"]} not found in parent IP')
                        sys.exit(1)
                    # Put the value into the IP
                    ip['params'][param_ix]['value'] = parent_value
                    ip['params'][param_ix]['parent_ip'] = fins_data['name']

    return fins_data


def find_base_address_from_qsys(filename, module_name, interface_name):
    # Assemble the name of the connection end where the address space is mapped
    connection_end = module_name + '.' + interface_name

    # Parse the Qsys XML file
    if not os.path.exists(filename):
        LOGGER.error(f'No file {filename} exists')
        sys.exit(1)
    tree = ET.parse(filename)
    root = tree.getroot()

    # Loop through all connections in the design
    for connection in root.findall('connection'):
        # Initialize to the attributes
        connection_def = connection.attrib

        # Only collect avalon memory-mapped connections
        if connection_def['kind'].lower() != 'avalon':
            continue

        # Check for connection match against connection end module_name.interface syntax
        if connection_def['end'].lower() != connection_end.lower():
            continue

        # Find the base_address
        for parameter in connection.findall('parameter'):
            if parameter.get('name') == 'baseAddress':
                try:
                    base_address = int(parameter.get('value'), 16)
                    return base_address
                except ValueError:
                    LOGGER.error(f'Unable to convert the base address from hex to int. Problem string: {parameter.get("value")}')
                    sys.exit(1)

        # If we haven't returned, it is an error
        LOGGER.error(f'Unable to find baseAddress parameter in qsys file {filename}')
        sys.exit(1)

    # If we haven't returned, it is an error
    LOGGER.error(f'Unable to find memory-mapped connection that matches {connection_end}')
    sys.exit(1)


def find_base_address_from_bd(filename, module_name, interface_name):
    # Open and load the vivado file
    with open(filename) as bd_file:
        bd_data = json.load(bd_file)

    # Find the base address
    for master_module in bd_data['design']['addressing'].values():
        for address_space in master_module['address_spaces'].values():
            for segment in address_space['segments'].values():
                if (module_name + '/' + interface_name) in segment['address_block']:
                    try:
                        base_address = int(segment['offset'], 16)
                        return base_address
                    except ValueError:
                        LOGGER.error(f'Unable to convert the base address from hex to int. Problem string: {segment["offset"]}')
                        sys.exit(1)

    # If we haven't returned, it is an error
    LOGGER.error(f'Unable to find address space for {interface_name} of {module_name} in {filename}')
    sys.exit(1)


def get_elem_with_name(fins_list, name, name_key="name"):
    """For a given list of fins dicts, find the element with the specified name.

    For example, get_elem_with_name(fins_ports, "myinput") will return the port in 'fins_ports'
    that is named "myinput", where 'fins_ports' is a list of dicts where each dict represents a
    port and has a 'name' field.

    Args:
        fins_list (list): a list of fins sub-dictionaries
        name (str): name of the element to retrieve
        name_key (str): what is the dict-key to use when getting the element name

    Returns:
        dict: the element with the provided name in fins_list
        None: if name isn't found
    """
    name_list = [n[name_key] for n in fins_list]
    if name not in name_list:
        return None
    elem_index = name_list.index(name)
    return fins_list[elem_index]


def get_signal_type(signal_name):
    """Given the name of a signal, determine whether it matches one of the type patterns (clock, reset...)
    If so, return that type, else return None

    Args:
        signal_name (str): name of the signal whose type should be retrieved
    
    Returns:
        str: the signal type string on success, None on failure
    """
    # Loop through the interface port inference dictionary
    for interface_type, signal_defs in INTERFACE_PORT_INFERENCE.items():
        for signal_def in signal_defs:
            # Search for an interface match for this signal name
            match_found = False
            if signal_def['regex']:
                # The pattern is a regular expression so search for match
                if re.search(signal_def['pattern'], signal_name, flags=re.IGNORECASE):
                    match_found = True
            else:
                # The pattern is not a regular expression so do a string compare
                if signal_def['pattern'].lower() == signal_name.lower():
                    match_found = True
            # Parse the interface
            if match_found:
                LOGGER.debug(f'Signal {signal_name} was determined to have type {interface_type}')
                return interface_type
    return None


def get_port(node_name, port_name, fins_data, port_type='ports'):
    """Get the port on the specified node in fins_data
    
    Args:
        node_name (str): node of interest in fins_data
        port_name (str): port being searched for in the node specified by node_name
        fins_data (dict): fins_data which may contain the specified node and its port

    Returns:
        dict: the sub-dictionary containing information for the port
    """
    # If a node is associated with the net, get the corresponding node in fins_data
    node = get_elem_with_name(fins_data['nodes'], node_name, name_key='module_name')

    # Get the port in this node if it exists
    if port_type not in node['node_details']['ports']:
        return None
    node_ports = node['node_details']['ports'][port_type]
    return get_elem_with_name(node_ports, port_name)


def get_hdl_port(node_name, port_name, fins_data):
    """Get the HDL port on the specified node in fins_data

    Args:
        node_name (str): node of interest in fins_data
        port_name (str): port being searched for in the node specified by node_name
        fins_data (dict): fins_data which may contain the specified node and its port

    Returns:
        dict: the sub-dictionary containing information for the port
    """
    return get_port(node_name, port_name, fins_data, port_type='hdl')


def get_any_port(node_name, port_name, fins_data):
    """Get the any port on the specified node in fins_data (AXIS or HDL)

    Args:
        node_name (str): node of interest in fins_data
        port_name (str): port being searched for in the node specified by node_name
        fins_data (dict): fins_data which may contain the specified node and its port

    Returns:
        dict: the sub-dictionary containing information for the port
    """
    hdl_port = get_port(node_name, port_name, fins_data, port_type='hdl')
    if hdl_port is not None:
        return hdl_port
    return get_port(node_name, port_name, fins_data, port_type='hdl')


def get_net_type(net, fins_data):
    """Given a net, return its type and its port (if the type is 'port' or 'hdl')

    Args:
        net_type (str): 'port' if the net is actually a node's port, 'hdl' if the net is an HDL port on a node,
                         otherwise the signal-type of this net ('clock' or 'reset')
                         None if the net is just a type-less signal
        port (dict): the port that this net matches based on its node and name (None if this "net" is not a port in the Application)

    Returns:
        str: the net type string on success ('port', 'hdl', signal_type, None (on failure))
        port: the port-subdictionary with information for this net, if this net is a port (type=port or hdl)
    """
    net_type = None
    port = None
    if 'node_name' in net:
        port = get_port(net['node_name'], net['net'], fins_data)

        if port is not None:
            net_type = 'port'
            #return 'port', port
        else:
            port = get_hdl_port(net['node_name'], net['net'], fins_data)
            if port is not None:
                net_type = 'hdl'

    if net_type is None:
        # Determine if the source net has an associated type (clock/reset...) and if so, get it
        net_type = get_signal_type(net['net'])

    return net_type, port


################################################################################
# Populate Entries in the FINS Data Dictionary
################################################################################

def populate_properties(fins_data,base_offset):
    # Make sure there are properties first
    if not 'properties' in fins_data:
        return fins_data

    # Loop through the properties to set defaults and validate values
    for prop in fins_data['properties']['properties']:
        # Make sure is_signed is not present and set to True
        # TODO: Implement is_signed
        if 'is_signed' in prop:
            if prop['is_signed']:
                LOGGER.error(f'The is_signed field defined for property {prop["name"]} is not implemented yet')
                sys.exit(1)

        # Set defaults
        if not 'description' in prop:
            prop['description'] = ''
        if not 'width' in prop:
            prop['width'] = fins_data['properties']['data_width']
        if not 'length' in prop:
            prop['length'] = 1
        if not 'default_values' in prop:
            prop['default_values'] = [0] * prop['length']
        if not 'disable_default_test' in prop:
            prop['disable_default_test'] = False
        if not 'is_signed' in prop:
            prop['is_signed'] = False
        if not 'range_min' in prop:
            if prop['is_signed']:
                prop['range_min'] = -2**(prop['width'] - 1)
            else:
                prop['range_min'] = 0
        if not 'range_max' in prop:
            if prop['is_signed']:
                prop['range_max'] = 2**(prop['width']-1) - 1
            else:
                prop['range_max'] = 2**prop['width'] - 1

        # Add additional fields based on the property type
        if 'read-only' in prop['type'].lower():
            prop['is_readable'] = True
            prop['is_writable'] = False
        elif 'write-only' in prop['type'].lower():
            prop['is_readable'] = False
            prop['is_writable'] = True
        else:
            prop['is_readable'] = True
            prop['is_writable'] = True

        # Validate that the length is >=1
        if prop['length'] < 1:
            LOGGER.error(f'The length of property {prop["name"]} is < 1')
            sys.exit(1)

        # Validate that the ranges are within valid widths
        if prop['is_signed']:
            if prop['range_max'] > 2**(prop['width']-1)-1:
                LOGGER.error(f'The range_max of property {prop["name"]} is larger than is possible for the signed bit width')
                sys.exit(1)
            if prop['range_min'] < -(2**(prop['width']-1)):
                LOGGER.error(f'The range_min of property {prop["name"]} is smaller than is possible for the signed bit width')
                sys.exit(1)
        else:
            if prop['range_max'] > 2**prop['width']-1:
                LOGGER.error(f'The range_max of property {prop["name"]} is larger than is possible for the unsigned bit width')
                sys.exit(1)
            if prop['range_min'] < 0:
                LOGGER.error(f'The range_min of property {prop["name"]} is smaller than is possible for the unsigned bit width')
                sys.exit(1)

        # If default_values is not a list, make it one
        if not isinstance(prop['default_values'], list):
            prop['default_values'] = [prop['default_values']]
        if len(prop['default_values']) != prop['length']:
            if len(prop['default_values']) == 1:
                prop['default_values'] = prop['default_values'] * prop['length']
            else:
                LOGGER.error(f'The number of elements in default_values of property {prop["name"]} does not match the property length')
                sys.exit(1)

    # Calculate offsets
    current_offset = base_offset
    for prop in fins_data['properties']['properties']:
        # Add the offset field to the register
        prop['offset'] = current_offset
        # Update the offset for the next register
        current_offset = current_offset + prop['length']

    # Validate that the address space is enough for the number of properties
    if fins_data['properties']['is_addr_byte_indexed']:
        num_bits_for_byte_indexing = math.ceil(math.log2(fins_data['properties']['data_width']/8))
        largest_possible_offset = 2**(fins_data['properties']['addr_width']-num_bits_for_byte_indexing )-1
    else:
        largest_possible_offset = 2**fins_data['properties']['addr_width']-1
    if current_offset > largest_possible_offset:
        LOGGER.error(f'The specified address width {fins_data["properties"]["addr_width"]} is not large enough to accomodate all the properties')
        sys.exit(1)

    # Return the modified dictionary
    return fins_data


def populate_ports(fins_data):
    # Loop through ports
    if 'ports' in fins_data:
        if 'ports' in fins_data['ports']:
            for port in fins_data['ports']['ports']:
                # Set defaults for port
                if not 'supports_backpressure' in port:
                    port['supports_backpressure'] = False
                if not 'supports_byte_enable' in port:
                    port['supports_byte_enable'] = False
                if not 'use_pipeline' in port:
                    port['use_pipeline'] = True
                if not 'num_instances' in port:
                    port['num_instances'] = 1
                # Set defaults for data fields
                if not 'bit_width' in port['data']:
                    port['data']['bit_width'] = 16
                if not 'is_complex' in port['data']:
                    port['data']['is_complex'] = False
                if not 'is_signed' in port['data']:
                    port['data']['is_signed'] = False
                if not 'num_samples' in port['data']:
                    port['data']['num_samples'] = 1
                if not 'num_channels' in port['data']:
                    port['data']['num_channels'] = 1
                # Set defaults for metadata fields
                if 'metadata' in port:
                    current_offset = 0
                    for metafield in port['metadata']:
                        # Set defaults for non-populated fields
                        if not 'bit_width' in metafield:
                            metafield['bit_width'] = 16
                        if not 'is_complex' in metafield:
                            metafield['is_complex'] = False
                        if not 'is_signed' in metafield:
                            metafield['is_signed'] = False
                        # Set and update the bit offset
                        metafield['offset'] = current_offset
                        current_offset = metafield['offset'] + metafield['bit_width']
                # Validate values
                if port['num_instances'] < 1:
                    LOGGER.error(f'The num_instances of port {port["name"]} is < 1')
                    sys.exit(1)

                # Check the data bit_width for limits
                if port['data']['bit_width'] < 8:
                    LOGGER.error(f'Port {port["name"]} data bit_width is smaller than the minimum value of 8')
                    sys.exit(1)
                elif port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] > 4096:
                    LOGGER.error(f'Port {port["name"]} total data width (bit_width*num_samples*num_channels) is larger than the maximum value of 4096')
                    sys.exit(1)
                
		# If the port supports byte enable, determine the number of bytes (rounded up) the port's
                # bit width is
                if 'supports_byte_enable':
                    bit_width = port['data']['bit_width']
                    num_samples = port['data']['num_samples']
                    num_channels = port['data']['num_channels']
                    port['data']['byte_width'] = math.ceil((bit_width * num_samples * num_channels) / 8)
                    port['data']['empty_width'] = math.ceil(math.log2(port['data']['byte_width']))
    # Return the modified dictionary
    return fins_data


def populate_filesets(fins_data):
    if not 'filesets' in fins_data:
        return fins_data

    design_file_keys = ['source', 'sim']
    for design_file_key in design_file_keys:
        if design_file_key in fins_data['filesets']:
            for design_file in fins_data['filesets'][design_file_key]:
                if not 'type' in design_file:
                    if '.dat' in design_file['path']:
                        design_file['type'] = 'dat'
                    elif '.hex' in design_file['path']:
                        design_file['type'] = 'hex'
                    elif '.mif' in design_file['path']:
                        design_file['type'] = 'mif'
                    elif '.vhd' in design_file['path']:
                        design_file['type'] = 'vhdl'
                    elif '.vhdl' in design_file['path']:
                        design_file['type'] = 'vhdl'
                    elif '.v' in design_file['path']:
                        design_file['type'] = 'verilog'
                    elif '.sv' in design_file['path']:
                        design_file['type'] = 'system_verilog'
                    else:
                        design_file['type'] = 'other'
                        LOGGER.warning(f'No type was provided or detected, so OTHER was assigned to {design_file["path"]} ... ONLY a concern with Quartus')

    if 'constraints' in fins_data['filesets']:
        for constraints_file in fins_data['filesets']['constraints']:
            if not 'type' in constraints_file:
                if '.sdc' in constraints_file['path']:
                    constraints_file['type'] = 'sdc'
                elif '.xdc' in constraints_file['path']:
                    constraints_file['type'] = 'xdc'
                else:
                    LOGGER.error(f'A type cannot be auto-detected from constraints file {constraints_file["path"]}')
                    sys.exit(1)

    if 'scripts' in fins_data['filesets']:
        script_keys = ['presim','postsim','prebuild','postbuild']
        for script_key in script_keys:
            if script_key in fins_data['filesets']['scripts']:
                for script_file in fins_data['filesets']['scripts'][script_key]:
                    if not 'type' in script_file:
                        if '.py' in script_file['path']:
                            script_file['type'] = 'python3'
                        elif '.m' in script_file['path']:
                            # NOTE: Default for .m files is Octave, not Matlab
                            script_file['type'] = 'octave'
                        elif '.tcl' in script_file['path']:
                            script_file['type'] = 'tcl'
                        elif '.sh' in script_file['path']:
                            script_file['type'] = 'cmdline'
                        else:
                            script_file['type'] = 'cmdline'
                            LOGGER.warning(f'No type provided or detected, so CMDLINE was assigned to {script_file["path"]}... ONLY a concern if command line execution not intended')
                            sys.exit(1)

        if 'vendor_ip' in fins_data['filesets']['scripts']:
            for script_file in fins_data['filesets']['scripts']['vendor_ip']:
                if not 'type' in script_file:
                    # There is only one option for this script type
                    script_file['type'] = 'tcl'

    return fins_data


def populate_ip(fins_data):
    # Only continue if this is applicable
    if not 'ip' in fins_data:
        return fins_data

    # Populate the sub-ip properties from the sub-ip JSON
    for ip in fins_data['ip']:
        # Load the sub-ip JSON file
        if os.path.exists(ip['fins_path']):
            with open(ip['fins_path']) as sub_ip_fins_file:
                sub_ip_fins_data = json.load(sub_ip_fins_file)
        else:
            LOGGER.error(f'No sub-ip file {ip["fins_path"]} exists')
            sys.exit(1)

        # Populate the sub-ip's properties
        ip['name'] = sub_ip_fins_data['name']
        if 'company_url' in sub_ip_fins_data:
            ip['vendor'] = sub_ip_fins_data['company_url']
        else:
            ip['vendor'] = 'user.org'
        if 'library' in sub_ip_fins_data:
            ip['library'] = sub_ip_fins_data['library']
        else:
            ip['library'] = 'user'
        if 'version' in sub_ip_fins_data:
            ip['version'] = sub_ip_fins_data['version']
        else:
            ip['version'] = '1.0.0'

    return fins_data


def populate_fins_fields(fins_data):
    if not 'version' in fins_data:
        fins_data['version'] = '1.0.0'
        LOGGER.debug(f'Setting default version to {fins_data["version"]}')
    if not 'company_url' in fins_data:
        fins_data['company_url'] = 'user.org'
        LOGGER.debug(f'Setting default company_url to {fins_data["company_url"]}')
    if not 'library' in fins_data:
        fins_data['library'] = 'user'
        LOGGER.debug(f'Setting default library to {fins_data["library"]}')
    if not 'top_source' in fins_data:
        fins_data['top_source'] = fins_data['name']
        LOGGER.debug(f'Setting default top_source to {fins_data["top_source"]}')
    if not 'top_sim' in fins_data:
        fins_data['top_sim'] = fins_data['name']+'_tb'
        LOGGER.debug(f'Setting default top_sim to {fins_data["top_sim"]}')
    if 'license_file' in fins_data:
        if not os.path.exists(fins_data['license_file']):
            LOGGER.error(f'provided license_file does not exist: {license_file}')
            sys.exit(1)
        else:
            with open(fins_data['license_file'], 'r', errors='ignore') as license_file:
                fins_data['license_lines'] = license_file.readlines()
            LOGGER.debug(f'reading license file "{fins_data["license_file"]}" to insert in generated files')

    return fins_data


def populate_hdl_inferences(fins_data):
    # Make sure the fins_data has the correct keys
    if not 'filesets' in fins_data:
        LOGGER.debug('No filesets in fins_data')
        return fins_data
    if not 'source' in fins_data['filesets']:
        LOGGER.debug('No source in filesets of fins_data')
        return fins_data

    top_file_descriptor = {}
    # Look for vhdl file in source filesets
    for source_file in fins_data['filesets']['source']:
        if '/'+fins_data['top_source']+'.vhd' in source_file['path']:
            if top_file_descriptor:
                LOGGER.error(f'Multiple VHDL source files match the top_source key {fins_data["top_source"]}')
                sys.exit(1)
            else:
                top_file_descriptor = source_file
                LOGGER.debug(f'Found the top-level {top_file_descriptor["type"]} file {top_file_descriptor["path"]}')
    # Look for verilog file in source filesets
    if not top_file_descriptor:
        for source_file in fins_data['filesets']['source']:
            if fins_data['top_source']+'.v' in source_file['path']:
                if top_file_descriptor:
                    LOGGER.error(f'Multiple VERILOG source files match the top_source key {fins_data["top_source"]}')
                    sys.exit(1)
                else:
                    top_file_descriptor = source_file
                    LOGGER.debug(f'Found the top-level {top_file_descriptor["type"]} file {top_file_descriptor["path"]}')

    # Make sure we found the top-level source file
    if not top_file_descriptor:
        LOGGER.warning(f'HDL inference failed because no source file matches the top_source key {fins_data["top_source"]}')
        return fins_data
    if not os.path.isfile(top_file_descriptor['path']):
        LOGGER.warning(f'HDL inference failed because the top-level source file does not exist {top_file_descriptor["path"]}')
        return fins_data

    # Initialize the fins_data dictionary
    fins_data['hdl'] = {'ports':[], 'generics':[], 'interfaces':[]}

    # Read the file
    with open(top_file_descriptor['path'], 'r') as top_file:
        top_file_contents = top_file.read()
        LOGGER.debug(f'Reading ports from {top_file_descriptor["path"]}')

    # Parse the ports and the generics
    if 'vhdl' in top_file_descriptor['type'].lower():
        # Find the entity
        vhdl_entity_find = re.findall(r'\s+entity\s+\w+\s+is.+?\s+end[\s;]',top_file_contents,flags=re.IGNORECASE|re.DOTALL)
        if not vhdl_entity_find:
            LOGGER.warning(f'HDL inference failed because no entity found in VHDL file {top_file_descriptor["path"]}')
            return fins_data
        if len(vhdl_entity_find) > 1:
            LOGGER.warning(f'HDL inference failed because the top level source file {top_file_descriptor["path"]} has multiple entities')
            return fins_data
        vhdl_entity = vhdl_entity_find[0]

        # Remove comments from entity
        # Regex note: Starts with -- and has 0 or more space, tab, or 
        #             non-whitespace character (purposefully omitting \r\n\f\v)
        vhdl_entity_comments = re.findall(r'--[ \t\S]*', vhdl_entity)
        for vhdl_entity_comment in vhdl_entity_comments:
            vhdl_entity = vhdl_entity.replace(vhdl_entity_comment,'')
            LOGGER.debug(f'Comment deleted {vhdl_entity_comment}')

        # Find the keywords to use for parsing
        vhdl_entity_generic_keyword = re.findall(r'\s+generic\s*\(',vhdl_entity,flags=re.IGNORECASE)
        if len(vhdl_entity_generic_keyword) > 1:
            LOGGER.warning(f'HDL inference failed because the top level source file {top_file_descriptor["path"]} has multiple generics lists')
            return fins_data
        if vhdl_entity_generic_keyword:
            vhdl_entity_generic_keyword = vhdl_entity_generic_keyword[0]
        vhdl_entity_port_keyword = re.findall(r'\s+port\s*\(',vhdl_entity,flags=re.IGNORECASE)
        if len(vhdl_entity_port_keyword) > 1:
            LOGGER.warning(f'HDL inference failed because the top level source file {top_file_descriptor["path"]} has multiple ports lists')
            return fins_data
        if vhdl_entity_port_keyword:
            vhdl_entity_port_keyword = vhdl_entity_port_keyword[0]
        else:
            LOGGER.warning(f'HDL inference failed because a port list was not detected in the top level source file {top_file_descriptor["path"]}')
            return fins_data

        # Find the ports
        # NOTE: Only ports of type "in", "out", and "inout" are supported
        vhdl_ports = re.findall(r'\w+\s*:\s*in\s+\w+[ \w)(-/*+]*',vhdl_entity,flags=re.IGNORECASE)
        vhdl_ports = vhdl_ports + re.findall(r'\w+\s*:\s*out\s+\w+[ \w)(-/*+]*',vhdl_entity,flags=re.IGNORECASE)
        vhdl_ports = vhdl_ports + re.findall(r'\w+\s*:\s*inout\s+\w+[ \w)(-/*+]*',vhdl_entity,flags=re.IGNORECASE)
        LOGGER.debug(f'Inferred ports from {top_file_descriptor["path"]}')
        for vhdl_port in vhdl_ports:
            LOGGER.debug(vhdl_port)
        for vhdl_port in vhdl_ports:
            # Parse the port into dictionary
            # NOTE: Only 'downto' syntax is supported for std_logic_vector
            new_port_descriptor = {}
            vhdl_port_parts = vhdl_port.partition(':')
            new_port_descriptor['name'] = vhdl_port_parts[0].strip()
            vhdl_port_definition = vhdl_port_parts[2].strip().partition(' ')
            new_port_descriptor['direction'] = vhdl_port_definition[0].strip()
            if not '(' in vhdl_port_definition[2]:
                new_port_descriptor['type'] = vhdl_port_definition[2].strip()
                new_port_descriptor['width'] = '1'
            else:
                vhdl_port_type = vhdl_port_definition[2].strip().partition('(')
                new_port_descriptor['type'] = vhdl_port_type[0].strip()
                vhdl_port_width = vhdl_port_type[2].strip().partition('downto')
                new_port_descriptor['width'] = vhdl_port_width[0].strip()+'+1'
            # Add to array of ports
            fins_data['hdl']['ports'].append(new_port_descriptor)

        # Find the generics
        if vhdl_entity_generic_keyword:
            # Isolate the generics list
            generic_keyword_partition = vhdl_entity.partition(vhdl_entity_generic_keyword)
            port_keyword_partition = generic_keyword_partition[2].strip().partition(vhdl_entity_port_keyword)
            vhdl_entity_generics = port_keyword_partition[0].strip()
            # Loop on string until empty
            while vhdl_entity_generics:
                # Find the current generic to parse and update the looping string
                current_generic_partition = vhdl_entity_generics.partition(';')
                current_generic = current_generic_partition[0].strip()
                vhdl_entity_generics = current_generic_partition[2].strip()
                if not vhdl_entity_generics:
                    # This is the last generic, need to remove the trailing );
                    last_generic_partition = current_generic.rpartition(')')
                    current_generic = last_generic_partition[0].strip()
                # Parse the generic
                # 1. Split into name and type+value
                # 2. Determine if type+value or just type
                # 3. Parse the value if applicable
                # 4. Determine if the type is std_logic_vector
                # 5. Parse the type and/or width
                # NOTE: Only "downto" syntax is supported for std_logic_vector
                new_generic_def = {}
                generic_partition = current_generic.partition(':')
                new_generic_def['name'] = generic_partition[0].strip()
                current_type_and_value = generic_partition[2].strip()
                if ':=' in current_type_and_value:
                    type_and_value_partition = current_type_and_value.partition(':=')
                    new_generic_def['value'] = type_and_value_partition[2].strip()
                    current_type = type_and_value_partition[0].strip()
                else:
                    current_type = current_type_and_value
                if not '(' in current_type:
                    new_generic_def['type'] = current_type.strip()
                else:
                    type_partition = current_type.partition('(')
                    new_generic_def['type'] = type_partition[0].strip()
                    width_partition = type_partition[2].strip().partition('downto')
                    try:
                        new_generic_def['width'] = int(width_partition[0].strip())+1
                    except ValueError:
                        LOGGER.warning(f'HDL inference failed because parsing the width specification of std_logic_vector generic encountered an error. Problem string: {width_partition[0].strip()}')
                        return fins_data
                # Add the generics array
                fins_data['hdl']['generics'].append(new_generic_def)

    else:
        LOGGER.warning('HDL inference failed because verilog top-level file not yet supported.')
        return fins_data

        # Find the module
        # NOTE: Verilog 2001 ANSI-style is assumed, i.e. `module foo #(PARAMETERS)(PORTS);`
        verilog_module_find = re.findall(r'\s+module\s+.)\s*;',top_file_contents,flags=re.IGNORECASE|re.DOTALL)
        if not verilog_module_find:
            LOGGER.error(f'No module found in verilog file {top_file_descriptor["path"]}')
            sys.exit(1)
        if len(verilog_module_find) > 1:
            LOGGER.error(f'The top level source file {top_file_descriptor["path"]} can not be read because has multiple modules')
            sys.exit(1)
        verilog_module = verilog_module_find[0]

        # Remove comments from module
        # Regex note: Starts with // and has 0 or more space, tab, or 
        #             non-whitespace character (purposefully omitting \r\n\f\v)
        verilog_module_comments = re.findall(r'//[ \t\S]*',verilog_module,flags=re.IGNORECASE)
        for verilog_module_comment in verilog_module_comments:
            verilog_module = verilog_module.replace(verilog_module_comment,'')
            LOGGER.debug('Comment deleted')

        # Figure out if the module has a parameter list (2001 ANSI-style)
        # NOTE: Parameters must have a default value
        verilog_module_parameters = re.findall(r'#\s*(.)',verilog_module,flags=re.IGNORECASE|re.DOTALL)
        if len(verilog_module_parameters) > 1:
            LOGGER.error(f'The top level source file {top_file_descriptor["path"]} can not be read because it has multiple parameter lists')
            sys.exit(1)
        if verilog_module_parameters:
            # Find the ports string
            verilog_module_parameters = verilog_module_parameters[0]
            verilog_module_ports = verilog_module.replace(verilog_module_parameters,'')
            # Parse the parameters
            previous_parameter_type = ''
            while verilog_module_parameters:
                # Find the current parameter to parse
                if ',' in verilog_module_parameters:
                    # There are more than 1 parameters to parse
                    module_partition = verilog_module_parameters.partition(',')
                    current_parameter = module_partition[0].strip()
                    # Update the remaining parameters to be parsed
                    verilog_module_parameters = module_partition[2].strip()
                else:
                    # This is the last parameter to parse
                    current_parameter = verilog_module_parameters
                    verilog_module_parameters = ''
                # Parse the parameter
                # 1. Delete the parameter keyword if exists
                # 2. Split into type+name and value
                # 3. Determine if type+name or just name
                # 4. Split type+name into type and name OR get name and infer type
                new_parameter_def = {}
                current_parameter = current_parameter.replace('parameter','')
                parameter_partition = current_parameter.partition('=')
                current_parameter_type_and_name = parameter_partition[0].strip()
                new_parameter_def['value'] = parameter_partition[2].strip()
                if ' ' in current_parameter_type_and_name:
                    type_and_name_partition = current_parameter_type_and_name.partition(' ')
                    new_parameter_def['name'] = type_and_name_partition[2].strip()
                    new_parameter_def['type'] = type_and_name_partition[0].strip()
                    # TODO: Infer parameter width
                else:
                    new_parameter_def['name'] = current_parameter_type_and_name
                    if previous_parameter_type:
                        new_parameter_def['type'] = previous_parameter_type
                    else:
                        # TODO: Infer parameter type
                        new_parameter_def['type'] = 'integer'
        else:
            verilog_module_ports = verilog_module

        # Parse the ports
        previous_port_def = {}
        while verilog_module_ports:
            # Find the current port to parse
            if ',' in verilog_module_ports:
                # There are more than 1 ports to parse
                module_partition = verilog_module_ports.partition(',')
                current_port = module_partition[0].strip()
                # Update the remaining ports to be parsed
                verilog_module_ports = module_partition[2].strip()
            else:
                # This is the last port to parse
                current_port = verilog_module_ports
                verilog_module_ports = ''
            # Parse the port
            new_port_def = {}
            if ' ' in current_port:
                # This is a port with a definition
                if '[' in current_port:
                    # This is a port with a bit width > 1
                    # NOTE: Only 'downto' syntax (i.e. [15:0]) is supported for std_logic_vector
                    port_partition = current_port.partition('[')
                    if 'input' in port_partition[0]:
                        new_port_def['direction'] = 'in'
                    elif 'output' in port_partition[0]:
                        new_port_def['direction'] = 'out'
                    else:
                        new_port_def['direction'] = 'inout'
                    port_width_and_name = port_partition[2]
                    width_and_name_partition = port_width_and_name.partition(':')
                    new_port_def['width'] = width_and_name_partition[0].strip()+'+1'
                    name_partition = width_and_name_partition[2].partition(']')
                    new_port_def['name'] = name_partition[2].strip()
                    new_port_def['type'] = 'std_logic_vector'
                else:
                    # This is a single bit port
                    port_partition = current_port.partition(' ')
                    if 'input' in port_partition[0]:
                        new_port_def['direction'] = 'in'
                    elif 'output' in port_partition[0]:
                        new_port_def['direction'] = 'out'
                    else:
                        new_port_def['direction'] = 'inout'
                    new_port_def['width'] = '1'
                    new_port_def['name'] = port_partition[2].strip()
                    new_port_def['type'] = 'std_logic'
                # Set the previous port def just in case thi sis the first in a port list (one definition, multiple ports)
                previous_port_def = new_port_def
            else:
                # This is a port that is second or greater in a port list (one definition, multiple ports)
                new_port_def['name'] = current_port
                new_port_def['type'] = previous_port_def['type']
                new_port_def['width'] = previous_port_def['width']
                new_port_def['direction'] = previous_port_def['direction']

    # Collect the interfaces
    unique_interface_ids = []
    for hdl_port in fins_data['hdl']['ports']:
        # Loop through the interface port inference dictionary
        for interface_type, signal_defs in INTERFACE_PORT_INFERENCE.items():
            for signal_def in signal_defs:
                # Search for an interface match for this signal name
                match_found = False
                if signal_def['regex']:
                    # The pattern is a regular expression so search for match
                    if re.search(signal_def['pattern'],hdl_port['name'],flags=re.IGNORECASE):
                        match_found = True
                else:
                    # The pattern is not a regular expression so do a string compare
                    if signal_def['pattern'].lower() == hdl_port['name'].lower():
                        match_found = True
                # Parse the interface
                if match_found:
                    # Add field to port
                    hdl_port['interface_signal'] = signal_def['properties']['signal']
                    # Parse interface details
                    interface_name = get_interface_name(interface_type, hdl_port)
                    interface_mode = get_interface_mode(interface_type, hdl_port, signal_def)
                    interface_id = interface_name+'::'+interface_mode
                    if interface_id in unique_interface_ids:
                        # Insert hdl_port into existing interface
                        for existing_interface in fins_data['hdl']['interfaces']:
                            if interface_id == existing_interface['id']:
                                existing_interface['hdl_ports'].append(hdl_port)
                    else:
                        # Create new interface
                        new_interface = {}
                        new_interface['name'] = interface_name
                        new_interface['type'] = interface_type
                        new_interface['mode'] = interface_mode
                        new_interface['id'] =   interface_id
                        new_interface['hdl_ports'] = []
                        new_interface['hdl_ports'].append(hdl_port)
                        unique_interface_ids.append(interface_id)
                        fins_data['hdl']['interfaces'].append(new_interface)
                    LOGGER.debug(f'Port {hdl_port["name"]} was associated to interface {interface_name} with type {interface_type}')

    LOGGER.debug(f'Inferred interfaces {unique_interface_ids}')

    return fins_data


def populate_property_interfaces(fins_data):
    """Modifies the contents of fins_data. Must be run after generator has been run for all sub-IPs/Nodes.

    Can only be called for Nodes and Applications (not Systems)

    Populate the per-node lists of property interfaces fins_data['prop_interfaces']
    and create the 'properties' clock domain with connections to each interface.

    A Node/IP's or an Application's prop_interfaces maps a node_name to a list of property interfaces
    on that Node:
        [
         {'name': <node-name>,
          'top':<top-interface>,
          'addr_width': <addr-width>,
          'data-width': <data-width>,
          'interfaces': [interface-dict, ...]
         }, ...
        ]

        Here, [interface-dict, ...] includes the interface dictionary of each sub-IP.
        An interface-dict contains:
            name: the simple and short name of this interface - same as name of containing IP/Node
            extended_name: includes the parent-Node name when inside an Application
            top: is this the interface of the top-IP in a hierarchy (not a sub-IP)?
                 Necessary because the top-IP's interface does not include the Node's name
                 (e.g. just S_AXI not S_AXI_TEST_MIDDLE)

    For Applications, this function adds a 'properties' clock domain dictionary to the fins_data['clocks'] list:
        [
         {
          'base_name': 'properties'
          'clock': 'properties_aclk'
          'resetn': 'properties_aresetn'
          'nets': [interface-net, ...]
         }
        ]

        Here, each interface-net is a dict  that contains the node_name, type=prop_interface
        and the actual interface (interface-dict explained above)
    """

    # Initialize the list of interfaces for this IP/Node: this is a list where each entry maps a node_name to a list of
    # property interfaces on that Node. A Node can have more than one prop interface when it has sub-IPs
    if fins_data['schema_type'] == SchemaType.NODE:

        fins_data['prop_interfaces'] = \
            [{
              'node_name': fins_data['name'],
              'addr_width': fins_data['properties']['addr_width'],
              'data_width': fins_data['properties']['data_width'],
              'interfaces': [{'name':fins_data['name'], 'top':True}]
            }] if 'properties' in fins_data else []

        if 'ip' in fins_data:
            for ip in fins_data['ip']:
                if len(ip['ip_details']['prop_interfaces']) > 0:
                    # Update the list of interfaces for this IP
                    # NOTE:
                    #     'ip_details' should have the interfaces of this IP's sub-IPs.
                    #     They were set by the above dictionary when this function was called for the sub-IP
                    ip_interfaces = ip['ip_details']['prop_interfaces'][0]['interfaces']
                    # These are sub-IPs so set their 'top' attribute to False
                    for interface in ip_interfaces:
                        interface['top'] = False

                    if len(fins_data['prop_interfaces']) == 0:
                        properties = ip['ip_details']['properties']
                        fins_data['prop_interfaces'] = \
                            [{
                              'node_name': fins_data['name'],
                              'addr_width': properties['addr_width'],
                              'data_width': properties['data_width'],
                              'interfaces': []
                            }]

                    fins_data['prop_interfaces'][0]['interfaces'] += ip_interfaces

    elif fins_data['schema_type'] == SchemaType.APPLICATION:
        # If this is an Application, collect all of the properties interfaces for its Nodes
        fins_data['prop_interfaces'] = []
        for node in fins_data['nodes']:
            if not node['descriptive_node'] and 'properties' in node['node_details']:
                prop_interface = {}
                prop_interface['node_name'] = node['module_name']
                prop_interface['addr_width'] = node['node_details']['properties']['addr_width']
                prop_interface['data_width'] = node['node_details']['properties']['data_width']
                prop_interface['interfaces'] = node['node_details']['prop_interfaces'][0]['interfaces']
                for interface in prop_interface['interfaces']:
                    # The extended name is used when exporting an interface from an Application and includes the
                    # name of the parent-IP (the one explicitly included in the Application)
                    # For example, if the Application includes a Node name "top" with a sub-IP named "bottom", and
                    # both have properties interfaces, the extended name will be "top_bottom"
                    #
                    # A Node with only a single interface will be named only by the module name
                    # (e.g. just "top" in the above example)
                    if len(prop_interface['interfaces']) > 1:
                        interface['extended_name'] = node['module_name'] + '_' + interface['name']
                    else:
                        interface['extended_name'] = node['module_name']

                fins_data['prop_interfaces'].append(prop_interface)


        if len(fins_data['prop_interfaces']) > 0:
            # For an Application, create the properties clock domain and connect it to all properties interfaces
            properties_clock = {
                                'base_name':'properties',
                                'clock':'properties_aclk',
                                'resetn':'properties_aresetn',
                                'period_ns':5,
                                'nets':[]
                               }
            for node_interfaces in fins_data['prop_interfaces']:
                for interface in node_interfaces['interfaces']:
                    properties_clock['nets'].append({'node_name':node_interfaces['node_name'], 'type':'prop_interface', 'interface':interface})

            fins_data['clocks'].append(properties_clock)

        LOGGER.debug(f'Property interfaces for "{fins_data["name"]}": {fins_data["prop_interfaces"]}')


def populate_fins_node(fins_data):
    """Modifies the contents of fins_data for a FINS Node.

    Populate contents specific to a FINS Node.
    """
    populate_property_interfaces(fins_data)


def populate_application_connections(fins_data):
    """Modifies the contents of fins_data for a FINS Application.

    Populate each connection in the Application so that each source and destination
    is associated with a type and port (if applicable). Port-port connections can 
    either be made on a per-port or per-instance basis: Port A connects to Port B 
    (all instances), or instance 0 of Port A connects to instance 1 of Port B.

    The fins_data['connections'] list is populated as follows:
        [
         {'source': source-dict,
          'destinations': [destination-dict],
         }, ...
        ]

        Here, each source-dict and destination-dict follows the same format:
            node_name
            net = which net on the node should be connected
            type = port or hdl
            port = if type is port or hdl, this is the actual port (dict) as found in the containing node
            instance = number which correlates to the index of the instance of the port
            connected = an array of booleans where the index correlates to the instance of a port
                        Instances are flagged as True if the instance of the port has one or more 
                        connections
    """

    # Initialize the ports with 'connected' set to False
    for node in fins_data['nodes']:
        if 'ports' in node['node_details']['ports']:
            # For all ports, initialize all values in an array of size num_instances to False
            for port in node['node_details']['ports']['ports']:
                port['connected'] = [False]*port['num_instances']
        if 'hdl' in node['node_details']['ports']:
            # For all hdls, initialize an array of size 1 with the value False
            for hdl_port in node['node_details']['ports']['hdl']:
                hdl_port['connected'] = [False]

    # if this Application has connections, iterate over the connections,
    # get and set the type and port (if applicable) of each source and destination net
    if 'connections' in fins_data:
        for connection in fins_data['connections']:
            source = connection['source']
            source['type'], source['port'] = get_net_type(source, fins_data)
            # Set default value for instance
            if source['type'] == 'port' and not 'instance' in source:
                source['instance'] = None
            # Each connection only has one source, but may have multiple destinations
            for destination in connection['destinations']:
                destination['type'], destination['port'] = get_net_type(destination, fins_data)
                # Set default value for instance
                if destination['type'] == 'port' and not 'instance' in destination:
                    destination['instance'] = None
                # For port-to-port connections, perform error checks to ensure connection would be valid
                if ((source['type'] == 'port' and destination['type'] == 'port') or
                    (source['type'] == 'hdl' and destination['type'] == 'hdl')):
                    # Flag port as 'connected'
                    # Handles case where the source type is not a port
                    if (source['type'] != 'port'):
                        source['port']['connected'][0] = True
                    # Handles case where the source type is a port but instance is not initialized in JSON
                    elif (source['instance'] == None):
                        for i in range(source['port']['num_instances']):
                            source['port']['connected'][i] = True
                    # Handles case where the source type is a port and instance is initialized in JSON
                    else:
                        source['port']['connected'][source['instance']] = True

                    # Handles case where the destination type is not a port
                    if (destination['type'] != 'port'):
                        destination['port']['connected'][0] = True
                    # Handles case where the destination type is a port but instance is not initialized in JSON
                    elif (destination['instance'] == None):
                        for i in range(destination['port']['num_instances']):
                            destination['port']['connected'][i] = True
                    # Handles case where the destination type is a port and instance is initialized in JSON
                    else:
                        destination['port']['connected'][destination['instance']] = True

def populate_application_clocks(fins_data):
    """Modifies the contents of fins_data for a FINS Application.

    Populate clock domains (fins_data['clocks']) and which nets they connect to:
        [
         {'base_name': <base_name>,
          'clock': <clock>,
          'resetn': <resetn>,
          'nets': [net-dict, ...]
         }, ...
        ]

        Here, base_name refers to the name of the clock domain (e.g. "iq" as opposed to "iq_aclk")
        'clock' and 'resetn' are the actual names of the clock and resetn (active low) names.
        And each 'net-dict' contains node_name, type (port or interface)
        and the actual 'port' or 'interface' being connected to.

    Sets the clock information on the actual port.
    """
    for clock in fins_data['clocks']:
        clock['base_name'] = clock['clock']

        if get_signal_type(clock['base_name']) != 'clock':
            clock['clock'] = clock['base_name'] + '_aclk'
            #reset_name = clock['base_name'] + '_aresetn'

        if 'resetn' not in clock:
            clock['resetn'] = clock['base_name'] + '_aresetn'

        if 'period_ns' not in clock:
            clock['period_ns'] = 5

        nets = clock['nets']
        for net in nets:
            net['type'], net['port'] = get_net_type(net, fins_data)
            LOGGER.debug(f'Connecting clock "{clock["clock"]}" to port "{net["port"]["name"]}" of type "{net["type"]}"')
            if (net['type'] == 'hdl' and
                (get_signal_type(net['net']) != 'clock' or net['port']['bit_width'] != 1)):
                LOGGER.error(f'To connect "hdl" port "{net["net"]}" to a clock it must be named as a clock and must have bit_width=1')
                sys.exit(1)
            elif net['type'] == 'port':
                net['port']['clock'] = clock['clock']
                net['port']['resetn'] = clock['resetn']
            elif net['type'] == 'hdl':
                net['port']['clock'] = clock['clock']


def populate_application_exports(fins_data):
    """Modifies the contents of fins_data for a FINS Application.

    Export ports that should be exposed externally from the Application.
    "Exporting" is another way of saying "make this an external port/interface of this Application"
    Exported ports are added to the fins_data['ports']['ports'] or fins_data['ports']['hdl'] lists

    By default, export all unconnected ports (ports and 'hdl' ports). If port_exports
    or hdl_exports is specified in the Application JSON, only export the ports listed
    in those fields.

    An exported port is a copied version of the original Node port with a few modified/extra fields:
        name: original port name prepended with the Node's module name
        node_name: name of the node that this port was exported from
        node_port: the original node port

    """
    # Export ports as ports of the Application itself
    if 'port_exports' in fins_data:
        if 'ports' not in fins_data:
            fins['ports'] = {}
        fins['ports']['ports'] = []

        for net in fins_data['port_exports']:
            # Get the port to export, copy it, change/add some information,
            # and add it to the Application's ports list
            port = get_port(net['node_name'], net['net'], fins_data)
            if port is None:
                LOGGER.error(f'Exported port not found {net["net"]}')
                sys.exit(1)

            application_port = port.copy()
            application_port['name'] = net['node_name'] + '_' + port['name']
            application_port['node_name'] = net['node_name']
            application_port['node_port'] = port
            fins_data['ports']['ports'].append(application_port)

    else:
        # If port_exports isn't present in the JSON, export all unconnected ports
        if 'ports' not in fins_data:
            fins_data['ports'] = {}
        fins_data['ports']['ports'] = []

        for node in fins_data['nodes']:
            # Only fully FINS-defined nodes are relevant here
            if not node['descriptive_node']:
                if 'ports' in node['node_details']['ports']:
                    for port in node['node_details']['ports']['ports']:
                        # does this port or any of its instances not connected?
                        port_unconnected = 'connected' not in port or False in port['connected'] 
                        # if any instance of the port is not connected, export it
                        if port_unconnected:
                            application_port = port.copy()
                            # Create a list of instances for the node that need to be exported for this port. These are the port-instances that will be present on the port of the application.
                            application_port['node_instances'] = []
                            for i in range(len(application_port['connected'])):
                                if application_port['connected'][i]:
                                    application_port['num_instances'] -= 1
                                else:
                                    application_port['node_instances'].append(i)
                            application_port['name'] = node['module_name'] + '_' + port['name']
                            application_port['node_name'] = node['module_name']
                            application_port['node_port'] = port
                            fins_data['ports']['ports'].append(application_port)

    # Export hdl ports as hdl ports of the Application itself
    if 'hdl_exports' in fins_data:
        if 'ports' not in fins_data:
            fins_data['ports'] = {}
        fins_data['ports']['hdl'] = []

        for net in fins_data['hdl_exports']:
            # Get the hdl port to export, copy it, change/add some information,
            # and add it to the Application's hdl ports list
            port = get_port(net['node_name'], net['net'], fins_data, port_type='hdl')
            if port is None:
                LOGGER.error(f'Exported port not found {net["net"]}')
                sys.exit(1)

            application_port = port.copy()
            application_port['name'] = net['node_name'] + '_' + port['name']
            application_port['node_name'] = net['node_name']
            application_port['node_port'] = port
            fins_data['ports']['hdl'].append(application_port)
    else:
        # If hdl_exports isn't present in the JSON, export all unconnected ports
        if 'ports' not in fins_data:
            fins_data['ports'] = {}
        fins_data['ports']['hdl'] = []

        for node in fins_data['nodes']:
            # Only fully FINS-defined nodes are relevant here
            if not node['descriptive_node']:
                if 'hdl' in node['node_details']['ports']:
                    for port in node['node_details']['ports']['hdl']:
                        # is this port part of a connection?
                        port_unconnected = 'connected' not in port or not port['connected'][0]

                        # if port is unconnected and is not tied to a clock source, export it
                        if port_unconnected and 'clock' not in port:
                            application_port = port.copy()
                            application_port['name'] = node['module_name'] + '_' + port['name']
                            application_port['node_name'] = node['module_name']
                            application_port['node_port'] = port
                            fins_data['ports']['hdl'].append(application_port)

    # If either list of ports is empty, delete it from the FINS data dictionary
    if not fins_data['ports']['ports']:
        del fins_data['ports']['ports']
    if not fins_data['ports']['hdl']:
        del fins_data['ports']['hdl']


def populate_fins_application_node(node):
    """Modifies the contents of 'node' dictionary. Must be run after run_generator has been for this Node.

    Determines/sets the following in the node dictionary:
        fins_dir:  is the source directory where this Node/IP originates
        node_name: original name of the node (not instance/module name) - comes from the Node itself
    """
    # In order to construct the path to the generated JSON for this node,
    # the user-authored JSON must first be loaded to determine its name
    # which is part of the file-path to the generated file

    node['fins_dir'] = os.path.dirname(node['fins_path']) #node_dir
    node['node_name'] = node['node_details']['name']


def populate_fins_application(fins_data):
    """Modifies the contents of fins_data for a FINS Application.

    Populate contents specific to a FINS Application.
    """
    for node in fins_data['nodes']:
        populate_fins_application_node(node)

    populate_application_connections(fins_data)
    populate_application_clocks(fins_data)
    populate_application_exports(fins_data)
    populate_property_interfaces(fins_data)


def populate_fins_system_node(node):
    """Modifies the contents of 'node' dictionary.

    Determines/sets various information relating to the node:
        node_name
        properties_offset
        properties
        node_id
        ports_producer/consumer
    """
    # Load the generated FINS JSON for the Node
    # and get the node_name from it
    node_fins_data = load_json_file(node['fins_path'])
    node['node_name'] = node_fins_data['name']

    ports_producer_name_defined = False
    ports_consumer_name_defined = False

    # Convert dictionary to uint
    if 'properties_offset' in node and isinstance(node['properties_offset'], str):
        if os.path.exists(node['properties_offset']):
            _, bd_extension = os.path.splitext(node['properties_offset'])
            if bd_extension.lower() == '.qsys':
                base_address = find_base_address_from_qsys(node['properties_offset'],node['module_name'],node['interface_name'])
            elif bd_extension.lower() == '.bd':
                base_address = find_base_address_from_bd(node['properties_offset'],node['module_name'],node['interface_name'])
            else:
                LOGGER.error(f'Unknown block design extension in FINS System: {bd_extension}')
                sys.exit(1)
            node['properties_offset'] = base_address
        else:
            LOGGER.warning(f'Properties offset path {node["properties_offset"]} for {node["module_name"]} does not exist')

    if 'properties' in node_fins_data and 'interface_name' not in node:
        LOGGER.error('a node with a properties interface must have an "interface_name" specified in the System')
        sys.exit(1)

    if 'properties' in node_fins_data:
        node['properties'] = node_fins_data['properties']['properties']
        node['node_id'] = node['node_name'] + '::' + node['module_name'] + '::' + node['interface_name']

    # Find the port listed in ports_producer_name
    if 'ports_producer_name' in node:
        # Make sure ports_producer_name is in only one node
        if ports_producer_name_defined:
            LOGGER.error('ports_producer_name can only be defined in one node')
            sys.exit(1)
        ports_producer_name_defined = True
        # Find the port
        ports_producer_found = False
        for port in node_fins_data['ports']['ports']:
            if node['ports_producer_name'].lower() == port['name'].lower():
                if port['direction'].lower() == 'in':
                    LOGGER.error('ports_producer was incorrectly assigned to an input port')
                    sys.exit(1)
                node['ports_producer'] = port
                ports_producer_found = True
        if not ports_producer_found:
            LOGGER.error(f'ports_producer_name {node["ports_producer_name"]} not found in node {node["node_name"]}')
            sys.exit(1)
    else:
        node['ports_producer_name'] = ''
        node['ports_producer'] = {}

    # Find the port listed in ports_consumer_name
    if 'ports_consumer_name' in node:
        # Make sure ports_consumer_name is in only one node
        if ports_consumer_name_defined:
            LOGGER.error('ports_consumer_name can only be defined in one node')
            sys.exit(1)
        ports_consumer_name_defined = True
        # Find the port
        ports_consumer_found = False
        for port in node_fins_data['ports']['ports']:
            if node['ports_consumer_name'].lower() == port['name'].lower():
                if port['direction'].lower() == 'out':
                    LOGGER.error('ports_consumer was incorrectly assigned to an output port')
                    sys.exit(1)
                node['ports_consumer'] = port
                ports_consumer_found = True
        if not ports_consumer_found:
            LOGGER.error(f'ports_consumer_name {node["ports_consumer_name"]} not found in node {node["node_name"]}')
            sys.exit(1)
    else:
        node['ports_consumer_name'] = ''
        node['ports_consumer'] = {}


def populate_fins_system(fins_data):
    """Modifies the contents of fins_data for a FINS System.

    Populate contents specific to a FINS System.
    """
    for node in fins_data['nodes']:
        populate_fins_system_node(node)


################################################################################
# Validation of the FINS JSON Schema and the Populated FINS Data Dictionary
################################################################################

def validate_schema(parent_key, schema_object):
    # Check the keys
    found_is_required = False
    found_types = False
    for key, value in schema_object.items():
        if not key in SCHEMA_KEYS:
            LOGGER.error(f'{parent_key} has an invalid key: {key}')
            sys.exit(1)
        if key.lower() == 'is_required':
            found_is_required = True
        if key.lower() == 'types':
            found_types = True
    if not (found_is_required and found_types):
        LOGGER.error(f'{parent_key} is missing the is_required or types key')
        sys.exit(1)
    # Check the types and the dependent keys
    for schema_object_type in schema_object['types']:
        if not schema_object_type in SCHEMA_TYPES:
            LOGGER.error(f'{parent_key} has an invalid type: {schema_object_type}')
            sys.exit(1)
    if 'list' in schema_object['types']:
        if not 'list_types' in schema_object:
            LOGGER.error(f'{parent_key} has no definition for the list types')
            sys.exit(1)
        for schema_list_type in schema_object['list_types']:
            if not schema_list_type in SCHEMA_LIST_TYPES:
                LOGGER.error(f'{parent_key} has an invalid list type: {schema_list_type}')
                sys.exit(1)
        if 'dict' in schema_object['list_types']:
            if not 'fields' in schema_object:
                LOGGER.error(f'{parent_key} has no definition for the fields in the dict list type')
                sys.exit(1)
    if 'dict' in schema_object['types']:
        if not 'fields' in schema_object:
            LOGGER.error(f'{parent_key} has no definition for the fields in the dict type')
            sys.exit(1)
    if ('list' in schema_object['types']) and ('dict' in schema_object['types']):
        LOGGER.error(f'{parent_key} cannot have both dict and list in the valid types')
        sys.exit(1)
    # Recursively check the fields
    if 'fields' in schema_object:
        if not (('list' in schema_object['types']) or ('dict' in schema_object['types'])):
            LOGGER.error(f'{parent_key} has a fields key but no dict or list type')
            sys.exit(1)
        for key, value in schema_object['fields'].items():
            validate_schema(key,value)
    # Notify of success
    LOGGER.debug(f'PASS: {parent_key}')


def validate_fins(parent_key,fins_object,schema_object):
    # Check type
    if type(fins_object) is list:
        if not 'list' in schema_object['types']:
            LOGGER.error(f'{parent_key} incorrectly has a list type')
            sys.exit(1)
    elif type(fins_object) is dict:
        if not 'dict' in schema_object['types']:
            LOGGER.error(f'{parent_key} incorrectly has a dict type')
            sys.exit(1)
    elif type(fins_object) is str:
        if not 'str' in schema_object['types']:
            LOGGER.error(f'{parent_key} incorrectly has a str type')
            sys.exit(1)
    elif type(fins_object) is int:
        if not 'int' in schema_object['types'] and not 'float' in schema_object['types']:
            LOGGER.error(f'{parent_key} incorrectly has a int type')
            sys.exit(1)
    elif type(fins_object) is float:
        if not 'float' in schema_object['types']:
            LOGGER.error(f'{parent_key} incorrectly has a float type')
            sys.exit(1)
    elif type(fins_object) is bool:
        if not 'bool' in schema_object['types']:
            LOGGER.error(f'{parent_key} incorrectly has a bool type')
            sys.exit(1)
    else:
        LOGGER.error(f'{parent_key} has an unknown type')
        sys.exit(1)
    # Check list types
    if type(fins_object) is list:
        for fins_object_element in fins_object:
            if type(fins_object_element) is dict:
                if not 'dict' in schema_object['list_types']:
                    LOGGER.error(f'{parent_key} incorrectly has a dict list type')
                    sys.exit(1)
            elif type(fins_object_element) is str:
                if not 'str' in schema_object['list_types']:
                    LOGGER.error(f'{parent_key} incorrectly has a str list type')
                    sys.exit(1)
            elif type(fins_object_element) is int:
                if not 'int' in schema_object['list_types'] and not 'float' in schema_object['list_types']:
                    LOGGER.error(f'{parent_key} incorrectly has a int list type')
                    sys.exit(1)
            elif type(fins_object_element) is float:
                if not 'float' in schema_object['list_types']:
                    LOGGER.error(f'{parent_key} incorrectly has a float list type')
                    sys.exit(1)
            elif type(fins_object_element) is bool:
                if not 'bool' in schema_object['list_types']:
                    LOGGER.error(f'{parent_key} incorrectly has a bool list type')
                    sys.exit(1)
            else:
                LOGGER.error(f'{parent_key} has an unknown list type')
                sys.exit(1)
    # Check the fields
    if 'dict' in schema_object['types']:
        # Check that the required schema keys are in the fins object
        for key, value in schema_object['fields'].items():
            if value['is_required'] and not (key in fins_object):
                LOGGER.error(f'Required key {key} does not exist in {parent_key}')
                sys.exit(1)
        # Check for fins object keys that are not in the schema object
        for key, value in fins_object.items():
            if not key in schema_object['fields'].keys():
                LOGGER.warning(f'Undefined key {key} in {parent_key}')
                continue
            # Recursively call this function on the fields
            validate_fins(key,value,schema_object['fields'][key])
    elif ('list' in schema_object['types']) and ('dict' in schema_object['list_types']):
        for fins_object_element in fins_object:
            # Check that the required schema keys are in the fins object
            for key, value in schema_object['fields'].items():
                if value['is_required'] and not (key in fins_object_element):
                    LOGGER.error(f'Required key {key} does not exist in {parent_key}')
                    sys.exit(1)
            # Check for fins object keys that are not in the schema object
            for key, value in fins_object_element.items():
                if not key in schema_object['fields'].keys():
                    LOGGER.warning(f'Undefined key {key} in {parent_key}')
                    continue
                # Recursively call this function on the fields
                validate_fins(key,value,schema_object['fields'][key])
    # Notify of success
    LOGGER.debug(f'PASS: {parent_key}')


def validate_files(fins_name,filename,file_list,allowed_types):
    # Iterate through the files
    for fins_file in file_list:
        # Assemble the path name
        if os.path.dirname(filename):
            filepath = os.path.dirname(filename)+'/'+fins_file['path']
        else:
            filepath = fins_file['path']
        # Check that the file exists
        if not os.path.isfile(filepath):
            LOGGER.error(f'File does not exist or path is incorrect {filepath}')
            sys.exit(1)
        # Check the type
        if 'type' in fins_file:
            if not (fins_file['type'].lower() in [allowed_type.lower() for allowed_type in allowed_types]):
                LOGGER.warning(f'Unknown type {fins_file["type"]} for file {filepath}')
        # Notify of success
        LOGGER.debug(f'PASS: {filepath}')


def validate_filesets(fins_data,filename):
    # Validate filesets
    LOGGER.debug(f'+++++ Validating filesets of {filename} ...')

    if 'source' in fins_data['filesets']:
        validate_files(fins_data['name'],filename,fins_data['filesets']['source'],QUARTUS_DESIGN_FILE_TYPES)
    elif fins_data['schema_type'] == SchemaType.NODE:
        LOGGER.error('Nodes must include the "source" fileset')
        sys.exit(1)

    if 'sim' in fins_data['filesets']:
        validate_files(fins_data['name'],filename,fins_data['filesets']['sim'],QUARTUS_DESIGN_FILE_TYPES)
    if 'constraints' in fins_data['filesets']:
        validate_files(fins_data['name'],filename,fins_data['filesets']['constraints'],CONSTRAINT_FILE_TYPES)
    if 'scripts' in fins_data['filesets']:
        if 'vendor_ip' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['vendor_ip'],VENDOR_SCRIPT_FILE_TYPES)
        if 'presim' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['presim'],SCRIPT_FILE_TYPES)
        if 'postsim' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['postsim'],SCRIPT_FILE_TYPES)
        if 'prebuild' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['prebuild'],SCRIPT_FILE_TYPES)
        if 'postbuild' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['postbuild'],SCRIPT_FILE_TYPES)
    LOGGER.debug('+++++ Done.')


def validate_ip(fins_data):
    # Collect parent parameter names
    parent_names = []
    if 'params' in fins_data:
        for param in fins_data['params']:
            parent_names.append(param['name'])
    # Iterate through the IP
    for ip in fins_data['ip']:
        # Make sure the IP file exists
        if not os.path.isfile(ip['fins_path']):
            LOGGER.error(f'IP does not exist or path {ip["fins_path"]} is incorrect')
            sys.exit(1)
        # Make sure all parameters have a parent
        if 'params' in ip:
            for param in ip['params']:
                if not param['parent'] in parent_names:
                    LOGGER.error(f'The parent for parameter {param["name"]} in IP {ip["fins_path"]} does not exist')
                    sys.exit(1)
        # Notify of success
        LOGGER.debug(f'PASS: {ip["fins_path"]}')


def validate_properties(fins_data):
    # Iterate through all properties
    prop_names = []
    for prop in fins_data['properties']['properties']:
        # Append to list of names
        prop_names.append(prop['name'])
        # Validate the property type
        if not prop['type'] in PROPERTY_TYPES:
            LOGGER.error(f'Property {prop["name"]} type {prop["type"]} is invalid')
            sys.exit(1)
        # Notify of success
        LOGGER.debug(f'PASS: Property {prop["name"]}')

    # Check for name duplicates
    if (len(prop_names) != len(set(prop_names))):
        LOGGER.error('Duplicate property names detected')
        sys.exit(1)

    # Set top-level defaults for properties interface
    if 'is_addr_byte_indexed' not in fins_data['properties']:
        fins_data['properties']['is_addr_byte_indexed'] = True


def validate_ports(fins_data):
    # Iterate through all FINS ports
    if 'ports' in fins_data['ports']:
        port_names = []
        for port in fins_data['ports']['ports']:
            # Add to the list of names
            port_names.append(port['name'])
            # Check the direction
            if not port['direction'] in PORT_DIRECTIONS:
                LOGGER.error(f'Port {port["name"]} direction {port["direction"]} is invalid')
                sys.exit(1)
            # Neither data nor metadata are required, but we must have at least one
            if not 'data' in port and not 'metadata' in port:
                LOGGER.error(f'Port {port["name"]} must have either metadata or data')
                sys.exit(1)
            # Notify of success
            LOGGER.debug(f'PASS: Port {port["name"]} with direction {port["direction"]}')

        # Check for name duplicates
        if (len(port_names) != len(set(port_names))):
            LOGGER.error('Duplicate port names detected')
            sys.exit(1)

    # Iterate through all FINS ports HDL
    if 'hdl' in fins_data['ports']:
        port_hdl_names = []
        for port_hdl in fins_data['ports']['hdl']:
            # Add to the list of names
            port_hdl_names.append(port_hdl['name'])
            # Check the direction
            if not port_hdl['direction'] in PORT_HDL_DIRECTIONS:
                LOGGER.error(f'Port HDL {port_hdl["name"]} direction {port_hdl["direction"]} is invalid')
                sys.exit(1)
            # Check that bit width is > 0
            bit_width = get_param_value(fins_data['params'], port_hdl['bit_width'])
            if bit_width < 1:
                LOGGER.error(f'Port HDL {port_hdl["name"]} must have a bit_width > 0')
                sys.exit(1)
            # Notify of success
            LOGGER.debug(f'PASS: Port HDL {port_hdl["name"]} with direction {port_hdl["direction"]}')

        # Check for name duplicates
        if (len(port_hdl_names) != len(set(port_hdl_names))):
            LOGGER.error('Duplicate port HDL names detected')
            sys.exit(1)


def validate_fins_data(fins_data, filename):
    LOGGER.debug('+++++ Loading JSON ...')
    with open(SCHEMA_FILENAME[fins_data['schema_type']]) as schema_data:
        fins_schema = json.load(schema_data)
    LOGGER.debug('+++++ Done.')

    # Validate the schema itself
    LOGGER.debug('+++++ Validating node.json ...')
    validate_schema('schema', fins_schema)
    LOGGER.debug('+++++ Done.')

    # Validate the FINS Node JSON file with the schema
    LOGGER.debug(f'+++++ Validating {filename} ...')
    validate_fins(SchemaType.get_str(fins_data), fins_data, fins_schema)
    LOGGER.debug('+++++ Done.')

    # Validate sub-IP
    if 'ip' in fins_data:
        LOGGER.debug(f'+++++ Validating ip of {filename} ...')
        validate_ip(fins_data)
        LOGGER.debug('+++++ Done.')

    # Validate properties
    if 'properties' in fins_data:
        LOGGER.debug(f'+++++ Validating properties of {filename} ...')
        validate_properties(fins_data)
        LOGGER.debug('+++++ Done.')

    # Validate ports
    if 'ports' in fins_data:
        LOGGER.debug(f'+++++ Validating ports of {filename} ...')
        validate_ports(fins_data)
        LOGGER.debug('+++++ Done.')


def _override_fins_data(fins_data, origfile, filename):
    """Looks for a <filename>.json.override file in the same directory and overrides params/part of the fins data

    Used to override the params/part of a Node in an Application or of a sub-IP of a Node
    """
    if (os.path.exists(filename)):
        # Open .override file
        with open(filename) as override_file:
            origpath = os.path.join(os.path.abspath(origfile))
            LOGGER.debug(f'FINS JSON file "{origpath}" is overridden by "{filename}"')
            override_data = json.load(override_file)
        # Override parameters
        if 'params' in override_data:
            for param_ix, param in enumerate(fins_data['params']):
                for edit_param in override_data['params']:
                    if (edit_param['name'].lower() == param['name'].lower()):
                        fins_data['params'][param_ix]['value'] = edit_param['value']
        # Override the part
        if 'part' in override_data:
            fins_data['part'] = override_data['part']
    return fins_data


def validate_and_convert_node_fins_data(fins_data, filename, backend):
    """Validates and converts data from a FINS Node JSON file
    """
    # Validate the FINS Node JSON using the node.json file
    validate_fins_data(fins_data,filename)

    # Set the backend used for generation
    fins_data['backend'] = backend

    # Override the FINS Node JSON data with a .override file if it exists
    fins_data = _override_fins_data(fins_data,filename,os.path.basename(filename)+'.override')

    # Replace any linked parameters with their literal values
    fins_data = convert_parameters_to_literal(fins_data)

    # Set defaults for top-level keys
    fins_data = populate_fins_fields(fins_data)

    # Apply property defaults and calculate offsets
    fins_data = populate_properties(fins_data,0)

    # Apply port defaults
    fins_data = populate_ports(fins_data)

    # Auto-detect file types
    fins_data = populate_filesets(fins_data)

    # Auto-detect sub-ip versions
    fins_data = populate_ip(fins_data)

    # Return
    return fins_data


def validate_node_fins_data_final(fins_data):
    """Final validation of the Node fins_data dictionary before
    generation is run for the Node
    """
    # Placeholder function
    pass


def validate_application_connections(fins_data):
    """For each pair of connection endpoints that are both ports,
    confirm that a connection between these ports would be valid

    Check that the following fields match within each pair of ports:
        supports_backpressure, num_instances, metadata, and data fields
    Confirm that the 'direction' field is opposite between the two connections.

    If the source and destination ports are a mismatch, print a helpful error message and exit.
    """
    if 'connections' in fins_data:
        for connection in fins_data['connections']:
            source = connection['source']
            for destination in connection['destinations']:
                src_port = source['port']
                dst_port = destination['port']
                src_name = source['node_name'] + '.' + source['net']
                dst_name = destination['node_name'] + '.' + destination['net']
                src_type = source['type']
                dst_type = destination['type']
                if (src_type == 'port' and dst_type == 'port'):
                    src_inst = source['instance']
                    dst_inst = destination['instance']
                if ((src_type == 'hdl' and dst_type == 'port') or
                      (src_type == 'port' and dst_type == 'hdl')):
                    LOGGER.error(f'One port is HDL and the other is AXIS in connection ({src_name}->{dst_name})')
                    sys.exit(1)
                elif src_port['direction'] == dst_port['direction']:
                    LOGGER.error(f'Ports of the same direction cannot be connected ({src_name}->{dst_name})')
                    sys.exit(1)
                elif src_type == 'port' and dst_type == 'port':
                    if src_port['supports_backpressure'] != dst_port['supports_backpressure']:
                        LOGGER.error(f'One port in connection ({src_name}->{dst_name}) supports backpressure, but the other does not')
                        sys.exit(1)
                    elif src_inst == None and dst_inst == None and src_port['num_instances'] != dst_port['num_instances']:
                        LOGGER.error(f'Ports in connection ({src_name}->{dst_name}) have different number of instances')
                        sys.exit(1)
                    elif src_inst == None and dst_inst != None and (src_port['num_instances'] != 1 or dst_inst >= dst_port['num_instances']):
                        LOGGER.error(f'Ports in connection ({src_name}->{dst_name}), the source has too many instances or an invalid instance was chosen for the destination')
                        sys.exit(1)
                    elif src_inst != None and dst_inst == None and (dst_port['num_instances'] != 1 or src_inst >= src_port['num_instances']):
                        LOGGER.error(f'Ports in connection ({src_name}->{dst_name}), the destination has too many instances or an invalid instance was chosen for the source')
                        sys.exit(1)
                    elif src_inst != None and dst_inst != None and (src_inst >= src_port['num_instances'] or dst_inst >= dst_port['num_instances']):
                        LOGGER.error(f'Ports in connection ({src_name}->{dst_name}) do not have the proper amount of instances for the index chosen')
                        sys.exit(1)
                    elif (('metadata' in src_port and 'metadata' not in dst_port) or
                          ('metadata' not in src_port and 'metadata' in dst_port) or
                          ('metadata' in src_port and 'metadata' in dst_port and src_port['metadata'] != dst_port['metadata'])):
                        LOGGER.error(f'Metadata does not match on ports in connection ({src_name}->{dst_name})')
                        sys.exit(1)
                    elif src_port['data'] != dst_port['data']:
                        if (src_port['data']['bit_width'] != dst_port['data']['bit_width'] or
                            src_port['data']['num_samples'] != dst_port['data']['num_samples'] or
                            src_port['data']['num_channels'] != dst_port['data']['num_channels']):

                            src_total_width = src_port['data']['bit_width']*src_port['data']['bit_width']*src_port['data']['bit_width']
                            dst_total_width = dst_port['data']['bit_width']*dst_port['data']['bit_width']*dst_port['data']['bit_width']
                            if src_total_width != dst_total_width:
                                LOGGER.error(f'bit_width*num_samples*num_channels does not match between ports in connection ({src_name}->{dst_name})')
                            else:
                                LOGGER.warning(f'bit_width, num_samples or num_channels do not match ports in connection ({src_name}->{dst_name}). bit_width*num_samples*num_channels matches... OK')
                            sys.exit(1)
                        elif (src_port['data']['is_complex'] != dst_port['data']['is_complex'] or
                              src_port['data']['is_signed'] != dst_port['data']['is_signed']):
                            LOGGER.warning(f'is_complex or is_signed does not match between ports in connection ({src_name}->{dst_name}). bit_width*num_samples*num_channels matches... OK.')
                elif ((src_type == 'hdl' and dst_type == 'hdl') and
                    src_port['bit_width'] != dst_port['bit_width']):
                    LOGGER.error(f'HDL Ports in connection ({src_name}->{dst_name}) do not have the same width')
                    sys.exit(1)


def validate_application_ports(fins_data):
    """Run port verification for Application ports.
    This function first calls the standard (Node) validate_ports()
    and then verifies that each port also has an associated Application clock
    """

    validate_ports(fins_data)

    if 'ports' in fins_data['ports']:
        for port in fins_data['ports']['ports']:
            # if this port has no clock, or if the clock is not found in fins_data's clocks list, error
            if 'clock' not in port or get_elem_with_name(fins_data['clocks'], port['clock'], name_key='clock') is None:
                LOGGER.error(f'Port {port["name"]} is not connected to a valid clock source')
                sys.exit(1)

def validate_and_convert_application_fins_data(fins_data, filename, backend):
    """Validates and converts data from a FINS Application JSON file
    """
    validate_fins_data(fins_data, filename)

    # Set the backend used for generation
    fins_data['backend'] = backend

    # Override the FINS Node JSON data with a .override file if it exists
    fins_data = _override_fins_data(fins_data, filename, os.path.basename(filename)+'.override')

    # Replace any linked parameters with their literal values
    fins_data = convert_parameters_to_literal(fins_data)

    # Set defaults for top-level keys
    fins_data = populate_fins_fields(fins_data)

    # Auto-detect file types
    fins_data = populate_filesets(fins_data)

    for node in fins_data['nodes']:
        # Set per-node defaults

        # By default, a node is standard/non-descriptive for Applications
        if 'descriptive_node' not in node:
            node['descriptive_node'] = False

    return fins_data


def validate_application_fins_data_final(fins_data):
    """Final validation of the Application fins_data dictionary before
    generation is run for the Application
    """
    validate_application_ports(fins_data)
    validate_application_connections(fins_data)


def validate_and_convert_system_fins_data(fins_data, filename, backend):
    """Validates and converts data from a FINS System JSON file
    """
    validate_fins_data(fins_data, filename)

    # Set the backend used for generation
    fins_data['backend'] = backend

    # Replace any linked parameters with their literal values
    fins_data = convert_parameters_to_literal(fins_data)

    # Set defaults for top-level keys
    fins_data = populate_fins_fields(fins_data)

    # Set defaults for System-specific top-level keys
    if 'base_offset' not in fins_data:
        fins_data['base_offset'] = 0

    for node in fins_data['nodes']:
        # Ensure that mandatory per-node keys are present
        if 'properties_offset' not in node:
            LOGGER.error(f'Required key properties_offset does not exist for node {node["module_name"]}')

        # Set per-node defaults

        # By default, a node is descriptive for Systems,
        if 'descriptive_node' not in node:
            node['descriptive_node'] = True

    return fins_data

def validate_system_fins_data_final(fins_data):
    """Final validation of the System fins_data dictionary before
    generation is run for the System
    """
    # Placeholder function
    pass


def post_generate_node_core(fins_data):
    """Operations that must occur after the 'core' generation is complete for a Node,
    but before backend generation starts
    """
    # Read top-level HDL code and find the ports
    # NOTE: Must be executed after populate_fins_fields() and after populate_filesets()
    fins_data = populate_hdl_inferences(fins_data)
    return fins_data
