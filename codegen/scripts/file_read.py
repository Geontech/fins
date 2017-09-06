#===============================================================================
# Company:      Geon Techonologies, LLC
# File:         read_ports.py
# Description:  Python script for parsing vhdl and verilog files to read
#               port types, names, and sizes used in files
#
# Revision History:
# Date          Author                  Revision
# ------------- ----------------------- ----------------------------------------
# 2017-07-12    Alex Newgent            Initial Version
#
#===============================================================================
import re
import os

class ip:
  #-----------------------------------------------------------------------------
  # Global Variable Declaration
  #-----------------------------------------------------------------------------
  file_name = ""
  file_type = ""
  # Eventual dictionary of ports
  # Keys: name, direction, type, lower_bound, upper_bound
  ports = []
  # Dictionary to track if buses are being used
  bus = {'s_axis':False, 'm_axis':False, 'sw_config':False}

  #-----------------------------------------------------------------------------
  # Initialize the Class
  #-----------------------------------------------------------------------------
  def __init__ ( self, ip_name ):
    self.file_name = ip_name
    # Check to see if file exists and check its filetype
    if os.path.isfile(ip_name + '.vhd'):
      self.file_type = 'VHDL'
    elif os.path.isfile(ip_name + '.v'):
      self.file_type = 'VERILOG'
    else:
      print('ERROR: Supported file type cannot be found')
      return;

    # Grab all the lines from the port map in the IP file
    words = self.get_ports()
    # Remove commented sections from words and assign the output to self.ports
    self.remove_comments(words)
    # Change self.ports from a list to a dict standard for both VHDL and Verilog
    self.ports = self.format_ports()
    # Check the 'name' keys to see if any known buses are being used
    self.check_bus()
    return;

  #-----------------------------------------------------------------------------
  # Grab the Entire Port Map
  #-----------------------------------------------------------------------------
  def get_ports ( self ):
    # Initialize empty list
    words = []
    # Assign variables dependent on file type
    if self.file_type == 'VHDL':
      # VHDL has 5 possible port directions, all listed here
      port_directions = ('in ','out ','inout ', 'buffer ', 'linkage ')
      # File extension to concatenate later
      extension = '.vhd'
      # String in file that signals beginning of port declaration
      port_map_flag = 'entity ' + self.file_name + ' is'
      # String in file that signals end of port declaration
      end_flag = 'end ' + self.file_name
    elif self.file_type == 'VERILOG':
      # Verilog has only 3 port directions
      port_directions = ('input ','output ','ioput ')
      extension = '.v'
      port_map_flag = 'module ' + self.file_name
      end_flag = ';'

    with open(self.file_name + extension, 'r') as fileID:
      # Find the beginning of module declaration
      for line in fileID:
        if re.search(port_map_flag, line, re.IGNORECASE):
          break

      # Grab all the lines that define ports
      for line in fileID:
        for i in port_directions:
          if (re.search(i, line, re.IGNORECASE)):
            # If true, add the entire line to bottom of the list
            words.append(line.split())
            break
        # Check if we're at the end of the port map
        if self.file_type == 'VHDL':
          if re.search(end_flag, line, re.IGNORECASE):
            break
        elif self.file_type == 'VERILOG':
          if end_flag in line:
            break
    return words;

  #-----------------------------------------------------------------------------
  # Remove any commented portions from words
  #-----------------------------------------------------------------------------
  def remove_comments( self, words ):
    # Figure out what denotes a comment based on file type
    if self.file_type == 'VHDL':
      comment_string = '--'
    elif self.file_type == 'VERILOG':
      comment_string = '//'
    # Entry in list consists of multiple strings
    for entry in words:
      uncommented = []
      for string in entry:
        # If the begining of a comment is found, consider the line
        # ended and stop adding it to the new list while also
        # removing un
        if comment_string in string or string == (',' or ';'):
          break
        elif ',' in string:
          # Prevents unwanted ',' in names of Verilog ports
          uncommented.append(string[:-1])

        elif ':' in string and self.file_type == 'VHDL':
          if string == ':':
            continue
          else:
            for i in string.split(':'):
              if i != '': uncommented.append(i)
        else:
          uncommented.append(string)
      # Add each new line with comments removed to ports (currently a list)
      self.ports.append(uncommented)
    return;

  #-----------------------------------------------------------------------------
  # Create a Dictionary with all of the port info
  #-----------------------------------------------------------------------------
  def format_ports ( self ):
    # Instantiate empty list of dictionaries
    port_info = []
    for entry in self.ports:
      info = {}
      # Grab the name and direction using booleans for index
      info['name'] = entry[-1*(self.file_type == 'VERILOG')]
      info['direction'] = entry[(self.file_type == 'VHDL')]

      # Check for characters indicating port is a bus
      if any(('(' or '[') in string for string in entry):
        info['type'],info['upper_bound'],info['lower_bound'] = self.get_size(entry)
      else:
        # Size doesn't matter for a wire, assign both to 0
        info['upper_bound'] = '0'
        info['lower_bound'] = '0'
        if self.file_type == 'VHDL':
          # Grab the type
          info['type'] = entry[2][:-1]
        else:
          # Verilog doesn't have types, just assign it as std_logic
          info['type'] = 'std_logic'
      port_info.append(info)
    return port_info;

  # Function to get size of buses (used in format_ports)
  def get_size ( self, entry ):
    # Store the list as a string
    buffer_string = ""
    for string in entry[1 + (self.file_type == 'VHDL'):]:
      buffer_string = buffer_string + string + ' '
    # Locate where the type and sizes are in the string
    if self.file_type == 'VHDL':
      start_point = buffer_string.index('(')
      end_point = buffer_string.rfind(')')
      if re.search(r'\bdownto\b',buffer_string,re.IGNORECASE):
        mid_point = buffer_string.lower().index(' downto ')
        # Need to skip the length of the string ' downto '
        size_adj = 7
        # downto indicates left string is the higher number
        left_is_high = True
      elif re.search(r'\bto\b',buffer_string,re.IGNORECASE):
        mid_point = buffer_string.lower().index(' to ')
        size_adj = 3
        left_is_high = False
      # Grab the string indicating port type
      mode = buffer_string[:start_point]
    else:
      # Indicators for Verilog
      start_point = buffer_string.index('[')
      mid_point = buffer_string.index(':')
      size_adj = 1
      end_point = buffer_string.index(']')
      left_is_high = True
      # Verilog doesn't declare types, just assume its std_logic_vector
      mode = 'std_logic_vector'

    # Grab the sizes out of the string
    left_bound = buffer_string[start_point+1:mid_point]
    right_bound = buffer_string[mid_point+size_adj:end_point]
    # Assign the size based on the 'to'/'downto' string
    if left_is_high:
      return [mode, left_bound, right_bound];
    else:
      return [mode, right_bound, left_bound];

  #---------------------------------------------------------------------------------
  # Function for checking if ports use any known bus
  #---------------------------------------------------------------------------------
  def check_bus ( self ):
    # Counter variables for known buses
    s_axi_cnt = 0
    m_axi_cnt = 0
    sw_cnt = 0
    for name in self.ports:
      if 's_axis' in name['name'].lower():
        # Port was found using string 's_axis'
        s_axi_cnt += 1
      elif 'm_axis' in name['name'].lower():
        # Port was found using string 'm_axis'
        m_axi_cnt += 1
      elif 'swconfig' in name['name'].lower():
        # Port was found using string 'sw_config'
        sw_cnt += 1
    # Alert user that bus type was found and save the data
    if s_axi_cnt > 1:
      self.bus['s_axis'] = True
      print('--> AXI-Stream Slave bus detected.')
    if m_axi_cnt > 1:
      self.bus['m_axis'] = True
      print('--> AXI-Stream Master bus detected.')
    if sw_cnt > 1:
      self.bus['sw_config'] = True
      print('--> Software Config bus detected.')
    return;
