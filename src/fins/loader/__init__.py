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

__all__ = (
    'load_fins_data'
)

SCHEMA_FILENAME = os.path.dirname(os.path.abspath(__file__)) + '/schema.json'
SCHEMA_TYPES = ['int', 'bool', 'str', 'list', 'dict']
SCHEMA_LIST_TYPES = ['int', 'bool', 'str', 'dict']
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
DESIGN_FILE_TYPES = ['vhdl', 'verilog']
SCRIPT_FILE_TYPES = ['matlab', 'octave', 'python', 'tcl']
CONSTRAINT_FILE_TYPES = ['xdc', 'sdc']
VENDOR_SCRIPT_FILE_TYPES = ['tcl']
# Regular expression strings used with re.search() on port names
# NOTE: Use re.IGNORECASE
INTERFACE_PORT_INFERENCE = {
    'reset':[
        { 'pattern':r'reset',        'regex':False,'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'\w+_reset',    'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'reset_\w+',    'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'\w+_reset_\w+','regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'resetin',      'regex':False,'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'\w+_resetin',  'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'resetn',       'regex':False,'properties':{'signal':'reset_n','polarity':'active_low' }},
        { 'pattern':r'\w+_resetn',   'regex':True, 'properties':{'signal':'reset_n','polarity':'active_low' }},
        { 'pattern':r'rst',          'regex':False,'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'\w+_rst',      'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'rstin',        'regex':False,'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'\w+_rstin',    'regex':True, 'properties':{'signal':'reset',  'polarity':'active_high'}},
        { 'pattern':r'aresetn',      'regex':False,'properties':{'signal':'reset_n','polarity':'active_low' }},
        { 'pattern':r'\w+_aresetn',  'regex':True, 'properties':{'signal':'reset_n','polarity':'active_low' }}
    ],
    'clock':[
        { 'pattern':r'clock',        'regex':False,'properties':{'signal':'clk'}},
        { 'pattern':r'\w+_clock',    'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'clock_\w+',    'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'\w+_clock_\w+','regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'clk',          'regex':False,'properties':{'signal':'clk'}},
        { 'pattern':r'\w+_clk',      'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'clkin',        'regex':False,'properties':{'signal':'clk'}},
        { 'pattern':r'\w+_clkin',    'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'aclk',         'regex':False,'properties':{'signal':'clk'}},
        { 'pattern':r'\w+_aclk',     'regex':True, 'properties':{'signal':'clk'}},
        { 'pattern':r'aclkin',       'regex':False,'properties':{'signal':'clk'}},
        { 'pattern':r'\w+_aclkin',   'regex':True, 'properties':{'signal':'clk'}}
    ],
    'axi4stream':[
        { 'pattern':r's\d*_axis_\w*_aclk|s\d*_axis_\w*_aclk',      'regex':True,'properties':{'mode':'slave',  'signal':'clk'    }},
        { 'pattern':r's\d*_axis_\w*_aresetn|s\d*_axis_\w*_aresetn','regex':True,'properties':{'mode':'slave',  'signal':'reset_n'}},
        { 'pattern':r's\d*_axis_\w*_tdata|s\d*_axis_\w*_tdata',    'regex':True,'properties':{'mode':'slave',  'signal':'tdata'  }},
        { 'pattern':r's\d*_axis_\w*_tvalid|s\d*_axis_\w*_tvalid',  'regex':True,'properties':{'mode':'slave',  'signal':'tvalid' }},
        { 'pattern':r's\d*_axis_\w*_tready|s\d*_axis_\w*_tready',  'regex':True,'properties':{'mode':'slave',  'signal':'tready' }},
        { 'pattern':r's\d*_axis_\w*_tstrb|s\d*_axis_\w*_tstrb',    'regex':True,'properties':{'mode':'slave',  'signal':'tstrb'  }},
        { 'pattern':r's\d*_axis_\w*_tkeep|s\d*_axis_\w*_tkeep',    'regex':True,'properties':{'mode':'slave',  'signal':'tkeep'  }},
        { 'pattern':r's\d*_axis_\w*_tlast|s\d*_axis_\w*_tlast',    'regex':True,'properties':{'mode':'slave',  'signal':'tlast'  }},
        { 'pattern':r's\d*_axis_\w*_tid|s\d*_axis_\w*_tid',        'regex':True,'properties':{'mode':'slave',  'signal':'tid'    }},
        { 'pattern':r's\d*_axis_\w*_tdest|s\d*_axis_\w*_tdest',    'regex':True,'properties':{'mode':'slave',  'signal':'tdest'  }},
        { 'pattern':r's\d*_axis_\w*_tuser|s\d*_axis_\w*_tuser',    'regex':True,'properties':{'mode':'slave',  'signal':'tuser'  }},
        { 'pattern':r'm\d*_axis_\w*_aclk|m\d*_axis_\w*_aclk',      'regex':True,'properties':{'mode':'master', 'signal':'clk'    }},
        { 'pattern':r'm\d*_axis_\w*_aresetn|m\d*_axis_\w*_aresetn','regex':True,'properties':{'mode':'master', 'signal':'reset_n'}},
        { 'pattern':r'm\d*_axis_\w*_tdata|m\d*_axis_\w*_tdata',    'regex':True,'properties':{'mode':'master', 'signal':'tdata'  }},
        { 'pattern':r'm\d*_axis_\w*_tvalid|m\d*_axis_\w*_tvalid',  'regex':True,'properties':{'mode':'master', 'signal':'tvalid' }},
        { 'pattern':r'm\d*_axis_\w*_tready|m\d*_axis_\w*_tready',  'regex':True,'properties':{'mode':'master', 'signal':'tready' }},
        { 'pattern':r'm\d*_axis_\w*_tstrb|m\d*_axis_\w*_tstrb',    'regex':True,'properties':{'mode':'master', 'signal':'tstrb'  }},
        { 'pattern':r'm\d*_axis_\w*_tkeep|m\d*_axis_\w*_tkeep',    'regex':True,'properties':{'mode':'master', 'signal':'tkeep'  }},
        { 'pattern':r'm\d*_axis_\w*_tlast|m\d*_axis_\w*_tlast',    'regex':True,'properties':{'mode':'master', 'signal':'tlast'  }},
        { 'pattern':r'm\d*_axis_\w*_tid|m\d*_axis_\w*_tid',        'regex':True,'properties':{'mode':'master', 'signal':'tid'    }},
        { 'pattern':r'm\d*_axis_\w*_tdest|m\d*_axis_\w*_tdest',    'regex':True,'properties':{'mode':'master', 'signal':'tdest'  }},
        { 'pattern':r'm\d*_axis_\w*_tuser|m\d*_axis_\w*_tuser',    'regex':True,'properties':{'mode':'master', 'signal':'tuser'  }}
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

def get_interface_name(interface_type, hdl_port):
    if interface_type == 'reset':
        return hdl_port['name']
    elif interface_type == 'clock':
        return hdl_port['name']
    elif interface_type == 'axi4stream':
        return hdl_port['name'].rpartition('_')[0]
    elif interface_type == 'axi4lite':
        return hdl_port['name'].rpartition('_')[0]
    elif interface_type == 'avalon_streaming':
        return hdl_port['name'].rpartition('_')[0]
    else:
        print('ERROR: Unsupported interface type',interface_type)
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

def validate_schema(parent_key,schema_object,verbose):
    # Check the keys
    found_is_required = False
    found_types = False
    for key, value in schema_object.items():
        if not key in SCHEMA_KEYS:
            print('ERROR:',parent_key,'has an invalid key:', key)
            sys.exit(1)
        if key.lower() == 'is_required':
            found_is_required = True
        if key.lower() == 'types':
            found_types = True
    if not (found_is_required and found_types):
        print('ERROR:',parent_key,'is missing the is_required or types key')
        sys.exit(1)
    # Check the types and the dependent keys
    for schema_object_type in schema_object['types']:
        if not schema_object_type in SCHEMA_TYPES:
            print('ERROR:',parent_key,'has an invalid type:', schema_object_type)
            sys.exit(1)
    if 'list' in schema_object['types']:
        if not 'list_types' in schema_object:
            print('ERROR:',parent_key,'has no definition for the list types')
            sys.exit(1)
        for schema_list_type in schema_object['list_types']:
            if not schema_list_type in SCHEMA_LIST_TYPES:
                print('ERROR:',parent_key,'has an invalid list type:', schema_list_type)
                sys.exit(1)
        if 'dict' in schema_object['list_types']:
            if not 'fields' in schema_object:
                print('ERROR:',parent_key,'has no definition for the fields in the dict list type')
                sys.exit(1)
    if 'dict' in schema_object['types']:
        if not 'fields' in schema_object:
            print('ERROR:',parent_key,'has no definition for the fields in the dict type')
            sys.exit(1)
    if ('list' in schema_object['types']) and ('dict' in schema_object['types']):
        print('ERROR:',parent_key,'cannot have both dict and list in the valid types')
        sys.exit(1)
    # Recursively check the fields
    if 'fields' in schema_object:
        if not (('list' in schema_object['types']) or ('dict' in schema_object['types'])):
            print('ERROR:',parent_key,'has a fields key but no dict or list type')
            sys.exit(1)
        for key, value in schema_object['fields'].items():
            validate_schema(key,value,verbose)
    # Notify of success
    if verbose:
        print('PASS:',parent_key)

def validate_fins(parent_key,fins_object,schema_object,verbose):
    # Check type
    if type(fins_object) is list:
        if not 'list' in schema_object['types']:
            print('ERROR:',parent_key,'incorrectly has a list type')
            sys.exit(1)
    elif type(fins_object) is dict:
        if not 'dict' in schema_object['types']:
            print('ERROR:',parent_key,'incorrectly has a dict type')
            sys.exit(1)
    elif type(fins_object) is str:
        if not 'str' in schema_object['types']:
            print('ERROR:',parent_key,'incorrectly has a str type')
            sys.exit(1)
    elif type(fins_object) is int:
        if not 'int' in schema_object['types']:
            print('ERROR:',parent_key,'incorrectly has a int type')
            sys.exit(1)
    elif type(fins_object) is bool:
        if not 'bool' in schema_object['types']:
            print('ERROR:',parent_key,'incorrectly has a bool type')
            sys.exit(1)
    else:
        print('ERROR:',parent_key,'has an unknown type')
        sys.exit(1)
    # Check list types
    if type(fins_object) is list:
        for fins_object_element in fins_object:
            if type(fins_object_element) is dict:
                if not 'dict' in schema_object['list_types']:
                    print('ERROR:',parent_key,'incorrectly has a dict list type')
                    sys.exit(1)
            elif type(fins_object_element) is str:
                if not 'str' in schema_object['list_types']:
                    print('ERROR:',parent_key,'incorrectly has a str list type')
                    sys.exit(1)
            elif type(fins_object_element) is int:
                if not 'int' in schema_object['list_types']:
                    print('ERROR:',parent_key,'incorrectly has a int list type')
                    sys.exit(1)
            elif type(fins_object_element) is bool:
                if not 'bool' in schema_object['list_types']:
                    print('ERROR:',parent_key,'incorrectly has a bool list type')
                    sys.exit(1)
            else:
                print('ERROR:',parent_key,'has an unknown list type')
                sys.exit(1)
    # Check the fields
    if 'dict' in schema_object['types']:
        # Check that the required schema keys are in the fins object
        for key, value in schema_object['fields'].items():
            if value['is_required'] and not (key in fins_object):
                print('ERROR: Required key',key,'does not exist in',parent_key)
                sys.exit(1)
        # Check for fins object keys that are not in the schema object
        for key, value in fins_object.items():
            if not key in schema_object['fields'].keys():
                print('WARNING: Undefined key',key,'in',parent_key)
                continue
            # Recursively call this function on the fields
            validate_fins(key,value,schema_object['fields'][key],verbose)
    elif ('list' in schema_object['types']) and ('dict' in schema_object['list_types']):
        for fins_object_element in fins_object:
            # Check that the required schema keys are in the fins object
            for key, value in schema_object['fields'].items():
                if value['is_required'] and not (key in fins_object_element):
                    print('ERROR: Required key',key,'does not exist in',parent_key)
                    sys.exit(1)
            # Check for fins object keys that are not in the schema object
            for key, value in fins_object_element.items():
                if not key in schema_object['fields'].keys():
                    print('WARNING: Undefined key',key,'in',parent_key)
                    continue
                # Recursively call this function on the fields
                validate_fins(key,value,schema_object['fields'][key],verbose)
    # Notify of success
    if verbose:
        print('PASS:',parent_key)

def validate_files(fins_name,filename,file_list,allowed_types,verbose):
    # Iterate through the files
    for fins_file in file_list:
        # Assemble the path name
        if os.path.dirname(filename):
            filepath = os.path.dirname(filename)+'/'+fins_file['path']
        else:
            filepath = fins_file['path']
        # Check that the file exists
        if not os.path.isfile(filepath):
            print('ERROR: File does not exist or path is incorrect',filepath)
            sys.exit(1)
        # Check the type
        if 'type' in fins_file:
            if not (fins_file['type'].lower() in [allowed_type.lower() for allowed_type in allowed_types]):
                print('ERROR: Invalid type',fins_file['type'],'for file',filepath)
        # Notify of success
        if verbose:
            print('PASS:',filepath)

def validate_ip(fins_data,verbose):
    # Collect parent parameter names
    parent_names = []
    if 'params' in fins_data:
        for param in fins_data['params']:
            parent_names.append(param['name'])
    # Iterate through the IP
    for ip in fins_data['ip']:
        # Make sure the IP file exists
        if not os.path.isfile(ip['fins_path']):
            print('ERROR: IP does not exist or path',ip['fins_path'],'is incorrect')
            sys.exit(1)
        # Make sure all parameters have a parent
        for param in ip['params']:
            if not param['parent'] in parent_names:
                print('ERROR: The parent for parameter',param['name'],'in IP',ip['fins_path'],'does not exist')
                sys.exit(1)
        # Notify of success
        if verbose:
            print('PASS:',ip['fins_path'])

def validate_properties(fins_data,verbose):
    # Iterate through all properties
    prop_names = []
    for prop in fins_data['properties']['properties']:
        # Append to list of names
        prop_names.append(prop['name'])
        # Validate the property type
        if not prop['type'] in PROPERTY_TYPES:
            print('ERROR: Property',prop['name'],'type',prop['type'],'is invalid')
            sys.exit(1)
        # Notify of success
        if verbose:
            print('PASS: Property',prop['name'])

    # Check for name duplicates
    if (len(prop_names) != len(set(prop_names))):
        print('ERROR: Duplicate property names detected')
        sys.exit(1)

def validate_ports(fins_data,verbose):
    # Iterate through all ports
    port_names = []
    for port in fins_data['ports']['ports']:
        # Add to the list of names
        port_names.append(port['name'])
        # Check the direction
        if not port['direction'] in PORT_DIRECTIONS:
            print('ERROR: Port',port['name'],'direction',port['direction'],'is invalid')
            sys.exit(1)
        # Neither data nor metadata are required, but we must have at least one
        if not 'data' in port and not 'metadata' in port:
            print('ERROR: Port',port['name'],'must have either metadata or data')
            sys.exit(1)
        # Notify of success
        if verbose:
            print('PASS: Port',port['name'],'with direction',port['direction'])

    # Check for name duplicates
    if (len(port_names) != len(set(port_names))):
        print('ERROR: Duplicate port names detected')
        sys.exit(1)

def get_param_value(params,key_or_value):
    if isinstance(key_or_value, str):
        for param in params:
            if key_or_value.lower() == param['name'].lower():
                return param['value']
        else:
            print('ERROR: {} not found in params'.format(key_or_value))
            sys.exit(1)
    else:
        return key_or_value

def convert_parameters_to_literal(fins_data,verbose):
    # Get the parameters
    params = []
    if 'params' in fins_data:
        params = fins_data['params']

    # Convert all non-string fields of ports to literals
    if 'ports' in fins_data:
        for port in fins_data['ports']['ports']:
            if 'data' in port:
                for key, value in port['data'].items():
                    # Convert value
                    port['data'][key] = get_param_value(params, value)
            if 'metadata' in port:
                for metafield in port['metadata']:
                    for key, value in metafield.items():
                        # Don't convert string typed fields
                        if (key.lower() == 'name'):
                            continue
                        # Convert value
                        metafield[key] = get_param_value(params, value)

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

    # Convert all string fields of ip to literals
    if 'ip' in fins_data:
        for ip in fins_data['ip']:
            # Make sure there are params
            if 'params' in ip:
                # Loop through parameters of IP
                for param_ix, param in enumerate(ip['params']):
                    # Get the value of parent parameter
                    parent_value = get_param_value(params, param['parent'])
                    if parent_value is None:
                        print('ERROR: {} of {} not found in parent IP'.format(param['parent'], ip['fins_path']))
                        sys.exit(1)
                    # Put the value into the IP
                    ip['params'][param_ix]['value'] = parent_value
                    ip['params'][param_ix]['parent_ip'] = fins_data['name']

    return fins_data

def populate_properties(fins_data,base_offset,verbose):
    # Make sure there are properties first
    if not 'properties' in fins_data:
        return fins_data

    # Loop through the properties to set defaults and validate values
    for prop in fins_data['properties']['properties']:
        # Make sure is_signed is not present and set to True
        # TODO: Implement is_signed
        if 'is_signed' in prop:
            if prop['is_signed']:
                print('ERROR: The is_signed field defined for property {} is not implemented yet'.format(prop['name']))
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
            print('ERROR: The length of property {} is < 1'.format(prop['name']))
            sys.exit(1)

        # Validate that the ranges are within valid widths
        if prop['is_signed']:
            if prop['range_max'] > 2**(prop['width']-1)-1:
                print('ERROR: The range_max of property {} is larger than is possible for the signed bit width'.format(prop['name']))
                sys.exit(1)
            if prop['range_min'] < -(2**(prop['width']-1)):
                print('ERROR: The range_min of property {} is smaller than is possible for the signed bit width'.format(prop['name']))
                sys.exit(1)
        else:
            if prop['range_max'] > 2**prop['width']-1:
                print('ERROR: The range_max of property {} is larger than is possible for the unsigned bit width'.format(prop['name']))
                sys.exit(1)
            if prop['range_min'] < 0:
                print('ERROR: The range_min of property {} is smaller than is possible for the unsigned bit width'.format(prop['name']))
                sys.exit(1)

        # If default_values is not a list, make it one
        if not isinstance(prop['default_values'], list):
            prop['default_values'] = [prop['default_values']]
        if len(prop['default_values']) != prop['length']:
            if len(prop['default_values']) == 1:
                prop['default_values'] = prop['default_values'] * prop['length']
            else:
                print('ERROR: The number of elements in default_values of property {} does not match the property length'.format(prop['name']))
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
        print('ERROR: The specified address width {} is not large enough to accomodate all the properties'.format(fins_data['properties']['addr_width']))
        sys.exit(1)

    # Return the modified dictionary
    return fins_data

def populate_ports(fins_data,verbose):
    # Make sure there are ports first
    if not 'ports' in fins_data:
        return fins_data

    # Loop through ports
    for port in fins_data['ports']['ports']:
        # Set defaults
        if not 'supports_backpressure' in port:
            port['supports_backpressure'] = False
        if not 'streaming_metadata' in port:
            port['streaming_metadata'] = False
        if 'data' in port:
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
        if 'metadata' in port:
            current_offset = 0
            for metafield in port['metadata']:
                # Set and update the bit offset
                metafield['offset'] = current_offset
                current_offset = metafield['offset'] + metafield['bit_width']
                # Set defaults for non-populated fields
                if not 'bit_width' in metafield:
                    metafield['bit_width'] = 16
                if not 'is_complex' in metafield:
                    metafield['is_complex'] = False
                if not 'is_signed' in metafield:
                    metafield['is_signed'] = False

        # Check the data bit_width for limits
        if 'data' in port:
            if port['data']['bit_width'] < 8:
                print('ERROR: Port',port['name'],'data bit_width is smaller than the minimum value of 8')
                sys.exit(1)
            elif port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] > 4096:
                print('ERROR: Port',port['name'],'total data width (bit_width*num_samples*num_channels) is larger than the maximum value of 4096')
                sys.exit(1)

    # Return the modified dictionary
    return fins_data

def populate_filesets(fins_data,verbose):
    if not 'filesets' in fins_data:
        return fins_data

    design_file_keys = ['source', 'sim']
    for design_file_key in design_file_keys:
        if design_file_key in fins_data['filesets']:
            for design_file in fins_data['filesets'][design_file_key]:
                if not 'type' in design_file:
                    if '.vhd' in design_file['path']:
                        design_file['type'] = 'vhdl'
                    elif '.vhdl' in design_file['path']:
                        design_file['type'] = 'vhdl'
                    elif '.v' in design_file['path']:
                        design_file['type'] = 'verilog'
                    else:
                        print('ERROR: A type cannot be auto-detected from design file',design_file['path'])
                        sys.exit(1)

    if 'constraints' in fins_data['filesets']:
        for constraints_file in fins_data['filesets']['constraints']:
            if not 'type' in constraints_file:
                if '.sdc' in constraints_file['path']:
                    constraints_file['type'] = 'sdc'
                elif '.xdc' in constraints_file['path']:
                    constraints_file['type'] = 'xdc'
                else:
                    print('ERROR: A type cannot be auto-detected from constraints file',constraints_file['path'])
                    sys.exit(1)

    if 'scripts' in fins_data['filesets']:
        script_keys = ['presim','postsim','prebuild','postbuild']
        for script_key in script_keys:
            if script_key in fins_data['filesets']['scripts']:
                for script_file in fins_data['filesets']['scripts'][script_key]:
                    if not 'type' in script_file:
                        if '.py' in script_file['path']:
                            script_file['type'] = 'python'
                        elif '.m' in script_file['path']:
                            # NOTE: Default for .m files is Octave, not Matlab
                            script_file['type'] = 'octave'
                        elif '.tcl' in script_file['path']:
                            script_file['type'] = 'tcl'
                        else:
                            print('ERROR: A type cannot be auto-detected from script file',script_file['path'])
                            sys.exit(1)

        if 'vendor_ip' in fins_data['filesets']['scripts']:
            for script_file in fins_data['filesets']['scripts']['vendor_ip']:
                if not 'type' in script_file:
                    # There is only one option for this script type
                    script_file['type'] = 'tcl'

    return fins_data

def populate_ip(fins_data,verbose):
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
            print('ERROR: No sub-ip file',ip['fins_path'],'exists')
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
            ip['version'] = '1.0'

    return fins_data

def populate_fins_fields(fins_data,verbose):
    if not 'version' in fins_data:
        fins_data['version'] = '1.0'
        if verbose:
            print('INFO: Setting default version to',fins_data['version'])
    if not 'company_url' in fins_data:
        fins_data['company_url'] = 'user.org'
        if verbose:
            print('INFO: Setting default company_url to',fins_data['company_url'])
    if not 'library' in fins_data:
        fins_data['library'] = 'user'
        if verbose:
            print('INFO: Setting default library to',fins_data['library'])
    if not 'top_source' in fins_data:
        fins_data['top_source'] = fins_data['name']
        if verbose:
            print('INFO: Setting default top_source to',fins_data['top_source'])
    if not 'top_sim' in fins_data:
        fins_data['top_sim'] = fins_data['name']+'_tb'
        if verbose:
            print('INFO: Setting default top_sim to',fins_data['top_sim'])
    return fins_data

def populate_hdl_inferences(fins_data,verbose):
    # Make sure the fins_data has the correct keys
    if not 'filesets' in fins_data:
        if verbose:
            print('INFO: No filesets in fins_data')
        return fins_data
    if not 'source' in fins_data['filesets']:
        if verbose:
            print('INFO: No source in filesets of fins_data')
        return fins_data

    top_file_descriptor = {}
    # Look for vhdl file in source filesets
    for source_file in fins_data['filesets']['source']:
        if fins_data['top_source']+'.vhd' in source_file['path']:
            if top_file_descriptor:
                print('ERROR: Multiple VHDL source files match the top_source key',fins_data['top_source'])
                sys.exit(1)
            else:
                top_file_descriptor = source_file
                if verbose:
                    print('INFO: Found the top-level',top_file_descriptor['type'],'file',top_file_descriptor['path'])
    # Look for verilog file in source filesets
    if not top_file_descriptor:
        for source_file in fins_data['filesets']['source']:
            if fins_data['top_source']+'.v' in source_file['path']:
                if top_file_descriptor:
                    print('ERROR: Multiple VERILOG source files match the top_source key',fins_data['top_source'])
                    sys.exit(1)
                else:
                    top_file_descriptor = source_file
                    if verbose:
                        print('INFO: Found the top-level',top_file_descriptor['type'],'file',top_file_descriptor['path'])

    # Make sure we found the top-level source file
    if not top_file_descriptor:
        print('ERROR: No source file matches the top_source key',fins_data['top_source'])
        sys.exit(1)
    if not os.path.isfile(top_file_descriptor['path']):
        print('ERROR: The top-level source file does not exist',top_file_descriptor['path'])
        sys.exit(1)

    # Initialize the fins_data dictionary
    fins_data['hdl'] = {'ports':[], 'generics':[], 'interfaces':[]}

    # Read the file
    with open(top_file_descriptor['path'], 'r') as top_file:
        top_file_contents = top_file.read()
        if verbose:
            print('INFO: Reading ports from',top_file_descriptor['path'])

    # Parse the ports and the generics
    if 'vhdl' in top_file_descriptor['type'].lower():
        # Find the entity
        vhdl_entity_find = re.findall(r'\s+entity\s+\w+\s+is.+?\s+end[\s;]',top_file_contents,flags=re.IGNORECASE|re.DOTALL)
        if not vhdl_entity_find:
            print('ERROR: No entity found in VHDL file',top_file_descriptor['path'])
            sys.exit(1)
        if len(vhdl_entity_find) > 1:
            print('ERROR: The top level source file',top_file_descriptor['path'],'can not be read because has multiple entities')
            sys.exit(1)
        vhdl_entity = vhdl_entity_find[0]

        # Remove comments from entity
        # Regex note: Starts with -- and has 0 or more space, tab, or 
        #             non-whitespace character (purposefully omitting \r\n\f\v)
        vhdl_entity_comments = re.findall(r'--[ \t\S]*', vhdl_entity)
        for vhdl_entity_comment in vhdl_entity_comments:
            vhdl_entity = vhdl_entity.replace(vhdl_entity_comment,'')
            if verbose:
                print('INFO: Comment deleted',vhdl_entity_comment)

        # Find the keywords to use for parsing
        vhdl_entity_generic_keyword = re.findall(r'\s+generic\s*\(',vhdl_entity,flags=re.IGNORECASE)
        if len(vhdl_entity_generic_keyword) > 1:
            print('ERROR: The top level source file',top_file_descriptor['path'],'can not be read because it has multiple generics lists')
            sys.exit(1)
        if vhdl_entity_generic_keyword:
            vhdl_entity_generic_keyword = vhdl_entity_generic_keyword[0]
        vhdl_entity_port_keyword = re.findall(r'\s+port\s*\(',vhdl_entity,flags=re.IGNORECASE)
        if len(vhdl_entity_port_keyword) > 1:
            print('ERROR: The top level source file',top_file_descriptor['path'],'can not be read because it has multiple ports lists')
            sys.exit(1)
        if vhdl_entity_port_keyword:
            vhdl_entity_port_keyword = vhdl_entity_port_keyword[0]
        else:
            print('ERROR: A port list was not detected in the top level source file',top_file_descriptor['path'])
            sys.exit(1)

        # Find the ports
        # NOTE: Only ports of type "in", "out", and "inout" are supported
        vhdl_ports = re.findall(r'\w+\s*:\s*in\s+\w+[ \w)(-/*+]*',vhdl_entity,flags=re.IGNORECASE)
        vhdl_ports = vhdl_ports + re.findall(r'\w+\s*:\s*out\s+\w+[ \w)(-/*+]*',vhdl_entity,flags=re.IGNORECASE)
        vhdl_ports = vhdl_ports + re.findall(r'\w+\s*:\s*inout\s+\w+[ \w)(-/*+]*',vhdl_entity,flags=re.IGNORECASE)
        if verbose:
            print('INFO: Inferred ports from',top_file_descriptor['path'])
            for vhdl_port in vhdl_ports:
                print(vhdl_port)
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
                        print('ERROR: Unable to parse the width specification of std_logic_vector generic. Problem string:',width_partition[0].strip())
                        sys.exit(1)
                # Add the generics array
                fins_data['hdl']['generics'].append(new_generic_def)

    else:
        print('ERROR: Verilog top-level file not yet supported.')
        sys.exit(1)

        # Find the module
        # NOTE: Verilog 2001 ANSI-style is assumed, i.e. `module foo #(PARAMETERS)(PORTS);`
        verilog_module_find = re.findall(r'\s+module\s+.)\s*;',top_file_contents,flags=re.IGNORECASE|re.DOTALL)
        if not verilog_module_find:
            print('ERROR: No module found in verilog file',top_file_descriptor['path'])
            sys.exit(1)
        if len(verilog_module_find) > 1:
            print('ERROR: The top level source file',top_file_descriptor['path'],'can not be read because has multiple modules')
            sys.exit(1)
        verilog_module = verilog_module_find[0]

        # Remove comments from module
        # Regex note: Starts with // and has 0 or more space, tab, or 
        #             non-whitespace character (purposefully omitting \r\n\f\v)
        verilog_module_comments = re.findall(r'//[ \t\S]*',verilog_module,flags=re.IGNORECASE)
        for verilog_module_comment in verilog_module_comments:
            verilog_module = verilog_module.replace(verilog_module_comment,'')
            print('INFO: Comment deleted',verilog_module_comment)

        # Figure out if the module has a parameter list (2001 ANSI-style)
        # NOTE: Parameters must have a default value
        verilog_module_parameters = re.findall(r'#\s*(.)',verilog_module,flags=re.IGNORECASE|re.DOTALL)
        if len(verilog_module_parameters) > 1:
            print('ERROR: The top level source file',top_file_descriptor['path'],'can not be read because it has multiple parameter lists')
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
                    if verbose:
                        print('INFO: Port',hdl_port['name'],'was associated to interface',interface_name,'with type',interface_type)
    if verbose:
        print('INFO: Inferred interfaces',unique_interface_ids)

    return fins_data

def override_fins_data(fins_data,filename,verbose):
    '''
    Looks for a <filename>.json.override file in the same directory and overrides params/part of the fins data
    '''
    if (os.path.exists(filename)):
        # Open .override file
        with open(filename) as override_file:
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

def validate_filesets(fins_data,filename,verbose):
    # Validate filesets
    if verbose:
        print('+++++ Validating filesets of {} ...'.format(filename))
    validate_files(fins_data['name'],filename,fins_data['filesets']['source'],DESIGN_FILE_TYPES,verbose)
    if 'sim' in fins_data['filesets']:
        validate_files(fins_data['name'],filename,fins_data['filesets']['sim'],DESIGN_FILE_TYPES,verbose)
    if 'constraints' in fins_data['filesets']:
        validate_files(fins_data['name'],filename,fins_data['filesets']['constraints'],CONSTRAINT_FILE_TYPES,verbose)
    if 'scripts' in fins_data['filesets']:
        if 'vendor_ip' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['vendor_ip'],VENDOR_SCRIPT_FILE_TYPES,verbose)
        if 'presim' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['presim'],SCRIPT_FILE_TYPES,verbose)
        if 'postsim' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['postsim'],SCRIPT_FILE_TYPES,verbose)
        if 'prebuild' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['prebuild'],SCRIPT_FILE_TYPES,verbose)
        if 'postbuild' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['postbuild'],SCRIPT_FILE_TYPES,verbose)
    if verbose:
        print('+++++ Done.')

def validate_fins_data(fins_data,filename,verbose):
    if verbose:
        print('+++++ Loading schema.json ...')
    with open(SCHEMA_FILENAME) as schema_data:
        fins_schema = json.load(schema_data)
    if verbose:
        print('+++++ Done.')

    # Validate the schema itself
    if verbose:
        print('+++++ Validating schema.json ...')
    validate_schema('schema',fins_schema,verbose)
    if verbose:
        print('+++++ Done.')

    # Validate the FINS Node JSON file with the schema
    if verbose:
        print('+++++ Validating {} ...'.format(filename))
    validate_fins('fins',fins_data,fins_schema,verbose)
    if verbose:
        print('+++++ Done.')

    # Validate sub-IP
    if 'ip' in fins_data:
        if verbose:
            print('+++++ Validating ip of {} ...'.format(filename))
        validate_ip(fins_data,verbose)
        if verbose:
            print('+++++ Done.')

    # Validate properties
    if 'properties' in fins_data:
        if verbose:
            print('+++++ Validating properties of {} ...'.format(filename))
        validate_properties(fins_data,verbose)
        if verbose:
            print('+++++ Done.')

    # Validate ports
    if 'ports' in fins_data:
        if verbose:
            print('+++++ Validating ports of {} ...'.format(filename))
        validate_ports(fins_data,verbose)
        if verbose:
            print('+++++ Done.')

def load_json_file(filename,verbose):
    """
    Loads data from a JSON file
    """
    # Load JSON
    if os.path.exists(filename):
        with open(filename) as fins_file:
            json_data = json.load(fins_file)
    else:
        print('ERROR: No file',filename,'exists')
        sys.exit(1)

    # Return
    return json_data

def find_base_address_from_qsys(filename, module_name, interface_name):
    # Assemble the name of the connection end where the address space is mapped
    connection_end = module_name + '.' + interface_name

    # Parse the Qsys XML file
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
                    print('ERROR: Unable to convert the base address from hex to int. Problem string:',parameter.get('value'))
                    sys.exit(1)

        # If we haven't returned, it is an error
        print('ERROR: Unable to find baseAddress parameter in qsys file',filename)
        sys.exit(1)

    # If we haven't returned, it is an error
    print('ERROR: Unable to find memory-mapped connection that matches',connection_end)
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
                        print('ERROR: Unable to convert the base address from hex to int. Problem string:',segment['offset'])
                        sys.exit(1)

    # If we haven't returned, it is an error
    print('ERROR: Unable to find address space for',interface_name,'of',module_name,'in',filename)
    sys.exit(1)

def validate_and_convert_fins_nodeset(fins_data,filename,verbose):
    """
    Validates and converts data from a Firmware IP Node Specification JSON build file
    """
    if not 'base_offset' in fins_data:
        fins_data['base_offset'] = 0
    ports_producer_defined = False
    ports_consumer_defined = False
    for node in fins_data['nodes']:
        # Convert dictionary to uint
        if isinstance(node['properties_offset'], dict):
            _, bd_extension = os.path.splitext(node['properties_offset']['block_design'])
            if bd_extension.lower() == '.qsys':
                base_address = find_base_address_from_qsys(node['properties_offset']['block_design'],node['properties_offset']['module_name'],node['properties_offset']['interface'])
            elif bd_extension.lower() == '.bd':
                base_address = find_base_address_from_bd(node['properties_offset']['block_design'],node['properties_offset']['module_name'],node['properties_offset']['interface'])
            else:
                print('ERROR: Unknown block design extension in FINS build:',bd_extension)
                sys.exit(1)
            node['properties_offset'] = base_address
        # Load FINS Node JSON for each node
        node['fins'] = load_json_file(node['fins_path'],verbose)
        # Set defaults
        if 'ports_producer' in node:
            if ports_producer_defined:
                print('ERROR: ports_producer can only be defined in one node')
                sys.exit(1)
            ports_producer_defined = True
        else:
            node['ports_producer'] = ''
        if 'ports_consumer' in node:
            if ports_consumer_defined:
                print('ERROR: ports_consumer can only be defined in one node')
                sys.exit(1)
            ports_consumer_defined = True
        else:
            node['ports_consumer'] = ''
    return fins_data

def validate_and_convert_fins_data(fins_data,filename,backend,verbose):
    """
    Validates and converts data from a Firmware IP Node Specification JSON file
    """
    # Validate the FINS Node JSON using the schema.json file
    validate_fins_data(fins_data,filename,verbose)

    # Set the backend used for generation
    fins_data['backend'] = backend

    # Override the FINS Node JSON data with a .override file if it exists
    fins_data = override_fins_data(fins_data,os.path.basename(filename)+'.override',verbose)

    # Replace any linked parameters with their literal values
    fins_data = convert_parameters_to_literal(fins_data,verbose)

    # Set defaults for top-level keys
    fins_data = populate_fins_fields(fins_data,verbose)

    # Apply property defaults and calculate offsets
    fins_data = populate_properties(fins_data,0,verbose)

    # Apply port defaults
    fins_data = populate_ports(fins_data,verbose)

    # Auto-detect file types
    fins_data = populate_filesets(fins_data,verbose)

    # Auto-detect sub-ip versions
    fins_data = populate_ip(fins_data,verbose)

    # Read top-level HDL code and find the ports
    # NOTE: Must be executed after populate_fins_fields() and after populate_filesets()
    fins_data = populate_hdl_inferences(fins_data,verbose)

    # Return
    return fins_data
