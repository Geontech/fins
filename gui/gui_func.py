#====================================================================================
# Company:     Geon Technologies, LLC
# File:        gui_func.py
# Description: Python script with common functions used in the FINS GUI
#
# Revision History:
# Date        Author            Revision
# ----------  ----------------- -----------------------------------------------------
# 2017-08-18  Alex Newgent      Initial Version
#
#====================================================================================
import pygtk
pygtk.require('2.0')
import gtk
import os
from collections import OrderedDict
#------------------------------------------------------------------------------------
# Common variables
#------------------------------------------------------------------------------------
# Default name for a parameters file
params_filename = "ip_params.json"
# Default name for an override parameters file
override_filename = "ip_override.json"
# Names of keys for parameter dicts
param_keys = ["name","value","type","used_in"]


# Keys for streams dict
stream_keys = ["name","mode","bit_width","is_complex","is_signed","packet_size"]

# Keys for registers dict
register_keys = ["name","address","default","bit_width"]

fileset_keys = ["source","sim","constraints","temp"]

ip_keys = ["name","repo_name","module_name","vendor","library","params"]

key_dict = {"params":param_keys,"registers":register_keys,"filesets":fileset_keys,"streams":stream_keys,"ip":ip_keys}

temp = ["*.cache", "*.data", "*.xpr", "*.log", "*.jou",
                            "*.hw", "component.xml", " xgui", "*.str",
                            "*.ip_user_files", "*.srcs",  "*.runs", "*.sim",
                            "*.txt", "*.mat", ".Xil", "*.coe", "*.edn",
                            "*.edif", "*_netlist.v", "*_netlist.vhd"]

# Path and filename of the window's logo image
IMG_STRING = "./fins_logo.png"

# List of mandatory parameters
mandatory_params = ["IP_NAME","IP_TOP","IP_TESTBENCH",
                    "IP_COMPANY_NAME","IP_COMPANY_URL","IP_COMPANY_LOGO",
                    "IP_DESCRIPTION"]

# Format order of the json parameters file
json_format =   OrderedDict([
                                ("params",[]),
                                ("ip",[]),
                                ("filesets",{}),
                                ("streams",[]),
                                ("registers",[])
                            ])

# List of error messages when editing parameters
error_message = ["ERROR: Name must begin with a letter (a-z or A-Z)",
                    "ERROR: Value and Type fields do not agree.",
                    "ERROR: Type must begin with a letter",
                    "ERROR: Mode must be either 'slave' or 'master'",
                    "ERROR: Item must be integer or parameter",
                    "ERROR: Name already in use"]

# Colors to use when printing messages (from X11 rgb.txt)
error_color = "firebrick1"
success_color = "black"
#------------------------------------------------------------------------------------
# Create a Button
#------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------
# Edit Parameters
#------------------------------------------------------------------------------------
# Saves the edits a user made to the entry boxes on the IP page
def cell_changed (cell, path, new_text, column, model,params,log=None):
    if new_text == model[path][column]:
        return
    name = model.get_name()
    if log:
        test = []
        for entry in model[path]:
            test.append(entry)
        test[column] = new_text
        errors = check_input(test, name, params,model,column)
        if errors:
            pass_err = []
            for entry in errors:
                if column in entry["pos"]:
                    pass_err.append(entry)
            if pass_err:
                update_log(log,pass_err)
                return;

    if name == "params":
        if (column == 0 or column == 2):
            if mandatory(model[path][0]):
                return;
    model[path][column] = new_text

# Allows the user to toggle non-mandatory check buttons
def cell_toggled (cell, path, column, model, treeview):
    if column == len(model[path])-1 and mandatory(model[path][0]):
            return;
    else:
        model[path][column] = not model[path][column]
        cell.set_property("active",model[path][column])
    return;

def change_box_colors (widget,color):
    widget.modify_text(gtk.STATE_NORMAL,gtk.gdk.color_parse(color))
    if type(widget) == type(gtk.ComboBoxEntry()):
        widget.get_child().modify_text(gtk.STATE_NORMAL,gtk.gdk.color_parse(color))
    parent = widget.get_parent().get_children()[1]
    parent.modify_fg(gtk.STATE_NORMAL,gtk.gdk.color_parse(color))

# Function for keyboard shortcut move
def move_param (widget, event, model):
    # Check if CTRL is being held
    if "GDK_CONTROL_MASK" in event.get_state().value_names:
        # Get the iter for the selected row
        position = widget.get_selection().get_selected()[1]
        # Get the integer position for the selected row
        int_pos = widget.get_selection().get_selected_rows()[1][0][0]
        # Grab the path for the current selected row
        curr_path = widget.get_cursor()
        # Create a list for the destination row
        next_path = list(curr_path[0])
        # Grab all the items in the selected row
        selected_row = []
        for item in model[position]:
            selected_row.append(item)
        # Move the selection up one row
        if event.keyval == 65362:
            # Check that we aren't at the top row
            if int_pos:
                # Delete the row and reinsert it one row up
                model.remove(position)
                model.insert(int_pos-1,selected_row)
                # Set the location of the next selected path
                next_path[0] = next_path[0]-1
        elif event.keyval == 65364:
            # Delete the row and reinsert it
            model.remove(position)
            if model.insert(int_pos+1,selected_row):
                # If the new location is valid, set it as the new selection
                next_path[0] = next_path[0]+1
        # Make the cursor follow the item the user is moving
        widget.set_cursor(curr_path[0])
        widget.get_selection().select_path(tuple(next_path))
    return;

# Delete the selected row of a tree model
def delete_row (widget, event,model):
    # Check that the button pressed was "Delete"
    if event.keyval == 65535:
        # Get the row's position
        position = widget.get_selection().get_selected()[1]
        # Make sure the position exists
        if position:
            # If the row is not mandatory, delete it
            if not any(model[position][0] in string for string in mandatory_params):
                del model[position]

def check_input (text, name, params,model, pos=0 ):
    error_list = []
    if pos == 0:
        i=0
        for row in model:
            if text[0] == row[0]:
                error_list.append({"message":error_message[5],"pos":[0]})
                break
    # Check that name begins with a letter
    if not (text[0] and text[0][0].isalpha()):
        error_list.append({"message":error_message[0],"pos":[0]})
    # Errors specific to the parameters page
    if name == "params":
        # Check that Type begins with a letter
        if not (text[2] and text[2][0].isalpha()):
            error_list.append({"message":error_message[2],"pos":[2]})
        if text[2] == "boolean":
            if text[1].lower() == "true" or text[1].lower() == "false":
                text[1] == text[1].lower()
            elif not any(text[1] == s[0] for s in params):
                error_list.append({"message":error_message[1],"pos":[1,2]})
        elif text[2] == "integer":
            if not text[1].isdigit():
                if not any(text[1] == s[0] for s in params):
                    error_list.append({"message":error_message[1],"pos":[1,2]})
    else:
        if name == "streams":
            if not any(text[1].lower() == s for s in ["master","slave"]):
                error_list.append({"message":error_message[3],"pos":[1]})
            start = 2
        else: start = 1
        for i,entry in enumerate(text[start:]):
            if not entry.isdigit():
                if not any(entry == s[0] for s in params):
                    if name=="ip":
                        k = 6
                    else:
                        k = 4
                    error_list.append({"message":error_message[k],"pos":[i+start]})
    return error_list;

# Checks if the parameter is in the mandatory params list
def mandatory (parameter):
    if not any(parameter == string for string in mandatory_params):
        return False;
    else:
        return True;
#------------------------------------------------------------------------------------
# Interact with the user
#------------------------------------------------------------------------------------
# Print messages to the error log
def update_log (log, messages,tag="error"):
    table = log.get_tag_table()
    text_color = table.lookup(tag)
    for error in messages:
        end_pos = log.get_end_iter()
        log.insert(end_pos,"\n " + error["message"])
        line_pos = log.get_iter_at_line(-1)
        end_pos = log.get_end_iter()
        log.apply_tag(text_color,line_pos,end_pos)

# Creates a pop-up used to select a file
def create_file_chooser (title,parent=None,string="*"):
    # Create the pop-up with the given title, parent, and two buttons
    sel = gtk.FileChooserDialog(title=title,
                                parent=parent,
                                action=gtk.FILE_CHOOSER_ACTION_OPEN,
                                buttons=("Select",True,"Cancel",False))
    if string == "folder":
        sel.set_action(gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER)
    sel.set_icon_from_file(IMG_STRING)

    # Add a filter to prevent certain files from being selected
    # Defaults to "*", which allows all files
    filt = gtk.FileFilter()
    filt.add_pattern(string)
    sel.add_filter(filt)
    # Run the pop up and grab the button's return value
    while True:
        ok = sel.run()
        if ok:
            name = sel.get_filename()
            if not any(string == s for s in ["folder","*"]):
                if string.replace("*","") in name:
                    sel.destroy()
                    return name;
            else:
                sel.destroy()
                return name;
        else:
            sel.destroy()
            return ok;

#------------------------------------------------------------------------------------
# Convenience functions
#------------------------------------------------------------------------------------
# Function that creates a box with a label and one widget
def create_label_widget (label, widget,shadow_type=gtk.SHADOW_NONE):
    frame = gtk.Frame(label)
    frame.set_shadow_type(shadow_type)
    frame.add(widget)
    return frame;

# Create a list store with given types
def create_model (parameters, col):
    # Create the list store with the types from col
    model = gtk.ListStore(*col)
    # Add each of the json parameters to the list
    for param in parameters:
        model.append(format_params(param))
    return model;

# Creates the scrolled window widget
def create_scroll_window ():
    scroll_box = gtk.ScrolledWindow()
    scroll_box.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
    return scroll_box;

# Create a gtk treeview
def create_tree (model,key,editable=True,form=[0],connect_func=delete_row,params=None,log=None):
    # Set the treeview model (should be a gtk ListStore)
    treeview = gtk.TreeView(model)
    key_list = []
    try:
        for entry in key_dict[key]:
            if entry == "used_in":
                key_list.extend(("HDL","MAT","TCL"))
            else:
                entry.replace("_"," ")
                key_list.append(entry.title())
    except:
        for entry in key:
            key_list.append(entry.title())

    # Connect the delete function. If none given, use default
    if connect_func == None:
        connect_func = delete_row
    treeview.connect("key-press-event",connect_func,model)
    # Connect a function for reordering the entries
    treeview.connect("key-press-event",move_param,model)

    # Allow the user to drag entries to reorder them
    treeview.set_reorderable(True)

    # Grab the length of the model
    model_length    = model.get_n_columns()
    cells           = []
    # Begin adding the appropriate cell renders to cells
    for i in range(model_length):
        # If form denotes a boolean, create a check button
        if form[i] == 2:
            cell = gtk.CellRendererToggle()
            cell.set_property("activatable",editable)
            cell.connect("toggled",cell_toggled,i,model,treeview)
        # If form denotes a combo box, create a combo box entry
        elif form[i] == 0:
            cell = gtk.CellRendererText()
            cell.set_property("editable",editable)
            cell.connect("edited",cell_changed,i,model,params,log)
        else:
            cell = gtk.CellRendererCombo()
            cell.set_property("editable",True)
            cell.set_property("has-entry",True)
            cell.set_property("model",form[i])
            cell.set_property("text-column",0)
            cell.connect("edited",cell_changed,i,model,params,log)
        # Otherwise, create an entry box
        cells.append(cell)

    # Use the model to fill out the needed information
    for i,key in enumerate(key_list):
        column = gtk.TreeViewColumn(key)
        # Check buttons use "active" instead of "text"
        if form[i]==2:
            column.pack_start(cells[i],expand=False)
            # The check button's state is chosen by the model at i
            column.set_attributes(cells[i],active=i)
        else:
            column.pack_start(cells[i],expand=True)
            # The text is taken from the model at i
            column.set_attributes(cells[i],text=i)
        # Give the column a sort ID
        column.set_sort_column_id(i)
        # Append the column to the treeview
        treeview.append_column(column)
    # Put in lines to divide each row
    treeview.set_grid_lines(True)
    treeview.show()
    return treeview;

# Create a list store of types that the user can choose from
def create_type_list ():
    type_list = ["string","integer","boolean","code"]
    types = gtk.ListStore(str)
    for text in type_list:
        types.append([text])
    return types;

# Function to create a GTK button
def create_button(text,connect_func,stock=None,expand=True,**connect_args):
    # Check if user wanted an image on the button
    if stock:
        # Create the button
        button = gtk.Button()
        # Create a box with the image and label
        hbox = add_image_label(stock,text,expand)
        # Add the box to the button
        button.add(hbox)
    else:
        # If no image, just put the text on the button
        button = gtk.Button(text)
    # Check if there are any connection arguments
    if not connect_args:
        button.connect("clicked",connect_func)
    else:
        button.connect("clicked",connect_func,connect_args)
    # Set the button to appear and return it
    button.show()
    return button;

# Creates a box with image and text for buttons
def add_image_label (stock,text,expand=True):
    hbox = gtk.HBox()
    img = gtk.Image()
    img.set_from_stock(stock,gtk.ICON_SIZE_BUTTON)
    hbox.pack_start(img,expand=False,fill=False,padding=0)
    hbox.pack_start(gtk.Label(text),expand=expand,fill=True,padding=5)
    hbox.show_all()
    return hbox;

# Format a dictionary to a list for use in a gtk ListStore
def format_item(item, key_list, buttons=False):
    # Create empty list
    data = []
    # Iterate the keys (should be ordered) and add them to the list
    for key in key_list:
        data.append(item[key])
    # If entries need check buttons (used_in), add them
    if buttons:
        # Iterate through names (usually set to "hdl","mat","tcl")
        for entry in buttons["names"]:
            # If the given parameter has these names, set the list entry to True
            data.append(entry in item[buttons["key"]])
    return data;

# Function for finding relative path between two paths
def get_relative_path (path1,path2):
    common_path = os.path.commonprefix([path1,path2])
    relative_path = os.path.relpath(path2,common_path)
    return relative_path;

# Searches param_dict for a parameter with the given name
def get_value(params_dict, param_name):
    for param in params_dict['params']:
        if param['name'] == param_name:
            return param['value']
    return ''

# Class for the top menu widget
class topmenu:
    # Substitute for a case statement
    colors = {  0: "grey93",
                1: "SteelBlue4",
                2: "DarkRed",
                3: "DarkGreen",
                4: "DarkSlateBlue",
                5: "grey0"}

    # Create a menu bar for the window
    def get_main_menu(self,window):
        accel_group = gtk.AccelGroup()
        item_factory = gtk.ItemFactory(gtk.MenuBar, "<main>",accel_group)
        item_factory.create_items(self.menu_items,window)
        window.add_accel_group(accel_group)
        self.item_factory = item_factory
        return item_factory.get_widget("<main>")

    # Function for changing the color in the window
    def day_theme (self,*args):
        window = args[0]
        eb = window.get_children()[0].get_children()[1]
        color_map = eb.get_colormap()
        color = color_map.alloc_color(self.colors[args[1]])
        style = eb.get_style().copy()
        style.bg[gtk.STATE_NORMAL] = color
        eb.set_style(style)

    def __init__(self,window,load_func,save_func):
        # Create boxes in the menu bar
        self.menu_items = (
            # Path name                 Key Shortcut    Function        Arg Widget Type
            ( "/_File",                 None,           None,           0,  "<Branch>"  ),
            ( "/File/Open",             "<control>O",   load_func,      0,  None        ),
            ( "/File/Save",             "<control>S",   save_func,      0,  None ),
            ( "/File/sep1",             None,           None,           0,  "<Separator>" ),
            ( "/File/Quit",             "<control>Q",   gtk.main_quit,  0,  None ),
            ( "/_Options",              None,           None,           0,  "<Branch>" ),
            ( "/Options/Theme",         None,           None,           0,  "<Branch>" ),
            ( "/Options/Theme/Gray",    None,           self.day_theme, 0,  None ),
            ( "/Options/Theme/Blue",    None,           self.day_theme, 1,  None ),
            ( "/Options/Theme/Red",     None,           self.day_theme, 2,  None ),
            ( "/Options/Theme/Green",   None,           self.day_theme, 3,  None ),
            ( "/Options/Theme/Purple",  None,           self.day_theme, 4,  None ),
            ( "/Options/Theme/Black",   None,           self.day_theme, 5,  None ),
            ( "/_Help",                 None,           None,           0, "<Branch>" ),
            ( "/_Help/About",           None,           None,           0, None ),
            )

        self.main_vbox = gtk.VBox(False, 1)
        self.main_vbox.set_border_width(1)
        self.main_vbox.show()

        menubar = self.get_main_menu(window)
        self.main_vbox.pack_start(menubar, False, True, 0)
