#!/usr/bin/python
#====================================================================================
# Company:      Geon Technologies, LLC
# File:         ip_func.py
# Description:  Main python script for the FINS GUI. Creates the GUI and handles all
#               the main functions
#
# Revision History:
# Date        Author            Revision
# ----------  ----------------- -----------------------------------------------------
# 2017-08-18  Alex Newgent      Initial Version
#
#====================================================================================
import pygtk
import json
pygtk.require('2.0')
import gtk
import os
import gui_func
from collections import OrderedDict
from ip_func import ip_page
from filesets_func import filesets_page
from scrolled_func import scrolled_page

#------------------------------------------------------------------------------------
# Class for the Main Window
#------------------------------------------------------------------------------------
class main_window:
    module_path = ""
    json_dict = gui_func.json_format
#------------------------------------------------------------------------------------
# Initialize and Main Functions
#------------------------------------------------------------------------------------
    # Initial function, creates the window
    def __init__(self):
        self.create_window()                # Create the main window
        self.create_error_log()             # Create the error logger
        self.create_notebook()              # Create tabbed window
        self.window.show_all()              # Show everything in the window
        self.notebook.set_current_page(0)   # Set the current page of the window
        gtk.main()                          # Start the main loop
        return;

#------------------------------------------------------------------------------------
# Initial Functions
#------------------------------------------------------------------------------------
    # Create the main window
    def create_window (self):
        # Create the main window
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        # Set the title and other details
        self.window.set_title("FINS")
        self.window.set_icon_from_file(gui_func.IMG_STRING)
        self.window.set_border_width(1)
        # Connect the closing functions
        self.window.connect("destroy",self.destroy)
        self.window.connect("delete_event",self.delete_event)
        # Add the main box to the window
        self.main_box = gtk.VBox()
        self.window.add(self.main_box)

    # Creates the error log at the bottom of the page
    def create_error_log (self):
        # Create top menu for saving and opening files
        menu = gui_func.topmenu(self.window,self.load_params_file,self.save_params)
        self.main_box.pack_start(menu.main_vbox,expand=False)

        # Create text buffer for error log
        self.log = gtk.TextBuffer()
        table = self.log.get_tag_table()

        # Create two font colors: one for errors, one for clears
        error_color = gtk.TextTag(name="error")
        error_color.set_property("foreground",gui_func.error_color)
        table.add(error_color)
        success = gtk.TextTag(name="success")
        success.set_property("foreground",gui_func.success_color)
        table.add(success)

        # Create a textview to hold the log buffer
        self.logger = gtk.TextView(self.log)
        # Do not allow users to edit the buffer
        self.logger.set_editable(False)

        # Create a scroll window to hold the buffer and allow it to scroll easier
        sw = gtk.ScrolledWindow()
        sw.set_policy(gtk.POLICY_AUTOMATIC,gtk.POLICY_AUTOMATIC)
        sw.add(self.logger)
        sw.set_size_request(-1,150)
        self.logger.connect("size-allocate",self.text_added,sw)
        self.page_box = gtk.VBox()

        # Create a box to hold the notebook and error log
        self.page_box.pack_end(sw,expand=False,fill=False,padding=5)

    # Forces text view to scroll to the bottom when text is added
    def text_added (self, widget, event, sw):
        adj = sw.get_vadjustment()
        adj.set_value(adj.upper - adj.page_size)

    # Function for creating each tab in the box
    def create_pages (self):
        # Create a dictionary for holding everything we'll pass to the class
        arg_dict = {}
        funcs = [self.add_item,self.clear_fields]
        # Arguments for the parameters tab
        # Forms uses 0 for entry, 1 or model name for ComboBoxEntry, and 2 for checks
        arg_dict["params"] = {"forms":[0,0,gui_func.create_type_list(),2,2,2]}
        arg_dict["params"]["func"] = self.delete_row
        # List for the drop-down menu on the streams tab
        mode_list = gtk.ListStore(str)
        for string in ["master","slave"]:
            mode_list.append([string])

        # Arguments for the streams tab
        # 1 signals use the parameters list store
        arg_dict["streams"] = {"forms":[0,mode_list,1,1,1,1]}

        # Arguments for the registers tab
        arg_dict["registers"] = {"forms" : [0,1,1,1]}
        # Temporary, unordered dictionary
        self.page_dict = OrderedDict()
        # Create the parameters page first
        self.page_dict["params"]= scrolled_page(self.json_dict,
                                                arg_dict["params"],
                                                "params",
                                                funcs,
                                                self.log)
        # Create the IP page
        self.page_dict["ip"] = ip_page(self.json_dict,
                                        self.window,
                                        self.module_path,
                                        self.page_dict["params"].store,
                                        self.log)
        # Create the filesets page
        self.page_dict["filesets"] = filesets_page(self.module_path)

        # Create the streams and registers pages
        for key in ["streams","registers"]:
            self.page_dict[key] = scrolled_page(self.json_dict,
                                                arg_dict[key],
                                                key,funcs,
                                                self.log,
                                                self.page_dict["params"].store)

        # Add the suggested parameters to the parameters page
        self.add_suggested_params()

    # Function for creating the tabbed window in the center
    def create_notebook (self):
        # Create the notebook pages
        self.create_pages()
        # Set up the notebook widget
        self.notebook = gtk.Notebook()
        # Add all the pages to the notebook
        for key in gui_func.json_format:
            if key == "ip":
                label = gtk.Label(key.upper())
            else:
                label = gtk.Label(key.title())
            self.notebook.append_page(self.page_dict[key].main_box,label)

        self.notebook.set_property("enable-popup",True) # Right click changes tab
        self.notebook.set_property("homogeneous",True)  # All tabs same size
        self.notebook.set_size_request(1050,600)

        self.page_box.pack_start(self.notebook,expand=True,fill=True,padding=5)
        # Create an event box (for formatting reasons only)
        eb = gtk.EventBox()
        # Add the page box to the event box
        eb.add(self.page_box)
        self.main_box.pack_start(eb)

#------------------------------------------------------------------------------------
# Import and Display Parameter Files
#------------------------------------------------------------------------------------
    # Function to allow user to choose their parameters file
    def load_params_file (self,widget=None, *data):
        # If a valid file was returned, grab useful info
        fullname = gui_func.create_file_chooser("Select Parameters File",self.window,"*.json")
        if fullname:
            # Split the full name into its directory path and file name
            self.module_path,params_file = os.path.split(fullname)
            self.find_params(fullname)
            self.module_path = self.module_path + "/"
            for key in ["filesets","ip"]:
                self.page_dict[key].path = self.module_path
        return;

    # Load parameters from an existing file
    def find_params (self, params_name):
        # Check if the path and file exist
        self.json_dict = OrderedDict()
        if os.path.exists(params_name):
            # Open and load the file into an ordered dictionary
            try:
                with open(params_name) as json_params_data:
                    self.json_dict = self.reorder_dict(json.load(json_params_data))
            except ValueError:
                error = {"message":"ERROR: JSON file improperly formatted!"}
                gui_func.update_log(self.log,[error])
                return False;
            else:
                success = {"message":"NOTE: JSON file successfully imported!"}
                gui_func.update_log(self.log,[success],"success")
            # Update all the pages with the new information
            self.update_pages()
            # Add the standard parameters
            self.add_suggested_params()
            return True;
        return False;

    # Function for formatting info from JSON file
    def reorder_dict (self,param_dict):
        json_dict = OrderedDict()
        for key in gui_func.json_format:
            # All the keys may not be used, so ask for forgiveness
            try:
                if key == "filesets":
                    # Filesets is the only dictionary
                    json_dict[key] = OrderedDict()
                    for i in gui_func.key_dict[key]:
                        try:
                            json_dict[key][i] = param_dict[key][i]
                        except KeyError:
                            # Param file was missing an entry, so we add it now
                            json_dict[key][i] = []
                else:
                    json_dict[key] = []
                    for entry in param_dict[key]:
                        temp = OrderedDict()
                        for key2 in entry:
                            temp[key2] = entry[key2]
                        json_dict[key].append(temp)
            except KeyError:
                if key == "filesets": json_dict[key] = OrderedDict()
                else: json_dict[key] = []
                error = {"message":"ERROR: "+key.title()+" not found! Adding now..."}
                gui_func.update_log(self.log,[error])
        return json_dict

    # Function to reset info on each notebook page
    def update_pages (self):
        # Update the IP page
        self.page_dict["ip"].param_store.clear()                # Clear IP stores
        self.page_dict["ip"].store = []
        self.page_dict["ip"].update_stored_ip(self.json_dict)
        self.page_dict["ip"].update_selections()
        # Update the common items in certain pages
        for key in ["params","streams","registers"]:
            # Clear the page's main list
            self.page_dict[key].store.clear()

        # Create the buttons dict that gives info on key and names of buttons
        buttons = {"key":"used_in","names":["hdl","mat","tcl"]}
        # Remove "used_in" from the list of text entry keys
        key_list = gui_func.param_keys[:-1]
        # Start creating the main list for the params page
        for param in self.json_dict["params"]:
            # Change the dictionary to a list useable by ListStore
            item = gui_func.format_item(param,key_list,buttons=buttons)
            # Add the list to the parameters store
            self.page_dict["params"].store.append(item)
        # Create the main lists for streams and registers
        for key in ["streams","registers"]:
            for entry in self.json_dict[key]:
                item = gui_func.format_item(entry,gui_func.key_dict[key])
                self.page_dict[key].store.append(item)

        # Create the main lists for the filsets page
        for key in gui_func.fileset_keys:
            self.page_dict["filesets"].store_dict[key].clear()
            for entry in self.json_dict["filesets"][key]:
                self.page_dict["filesets"].store_dict[key].append([entry])
        self.page_dict["filesets"].path = self.module_path

    # Adds useful parameters to the params list
    def add_suggested_params (self):
        for param in reversed(gui_func.mandatory_params):
            if not any(param in row[0] for row in self.page_dict["params"].store):
                sugg_param = [param,"","string",False,False,True]
                self.page_dict["params"].store.prepend(sugg_param)

#------------------------------------------------------------------------------------
# Save parameters to file
#------------------------------------------------------------------------------------
    # Function called when "save parameters" is clicked
    def save_params (self,widget=None, *data):
        if not self.module_path:
            self.module_path = gui_func.create_file_chooser("Save As",self.window,"folder")
            if not self.module_path: return
            for key in ["filesets","ip"]:
                self.page_dict[key].path = self.module_path
        # Grab all the parameters from the GUI tabs
        curr_dict   = self.get_params()
        # Compare curr_dict with self.json_dict to see what (if anything) was changed
        over_dict,edited,prompt   = self.check_diff(curr_dict)
        deleted = self.check_del(curr_dict)

        # If anything was edited, check where to save differences
        if prompt:
            buttons = ("Overwrite", 1, "Create Override", 2, "Cancel",3)
            text = "Parameters file found!\nWould you like to overwrite it?\n"
            override = self.overwrite_prompt(buttons = buttons, text = text)
        elif deleted or edited:
            buttons = ("Overwrite", 1, "Cancel", 3)
            text = "Save changes?"
            override = self.overwrite_prompt(buttons=buttons,text=text)
        else:
            message = {"message":"WARNING: Nothing to save."}
            gui_func.update_log(self.log,[message])
            return;

        if override == 1:
            # User wants to overwrite, or all changes are to names or deletes
            filename = self.module_path+"/"+gui_func.params_filename
            # Update the saved dict with the new one
            self.json_dict = curr_dict
            with open(filename,"w") as json_file:
                json.dump(self.json_dict,json_file,indent=2)
            message = {"message":"Note: Successfully wrote to "+filename}
            gui_func.update_log(self.log,[message],"success")
        elif override == 2:
            # User wants to send changes to an override file
            filename = self.module_path+"/"+gui_func.override_filename
            # Save all the changed parameters to the override file
            with open(filename,"w") as json_file:
                json.dump(over_dict,json_file)
            message = {"message":"Note: Successfully wrote to "+filename}
            gui_func.update_log(self.log,[message],"success")
            # Save all the deletes and name changes to the params file
            if deleted or edited:
                filename = self.module_path+"/"+gui_func.params_filename
                with open(filename,"w") as json_file:
                    json.dump(self.json_dict,json_file,indent=2)
            message = {"message":"Note: Add deletes and name changes to "+filename}
            gui_func.update_log(self.log,[message],"success")
        else:
            return;

    def check_diff(self,curr_dict):
        # Answer is True if a new parameter was added, or a name was changed
        answer = False
        # Prompt is true if a parameter was edited (anywhere but name)
        prompt = False
        override_dict = OrderedDict()
        for key in curr_dict:
            try: self.json_dict[key]
            except KeyError:
                override_dict[key] = curr_dict[key]
                answer=True
            else:
                if key == "filesets":
                    override_dict[key] = OrderedDict()
                    for key2 in curr_dict[key]:
                        override_dict[key][key2] = []
                        for entry in curr_dict[key][key2]:
                            try:
                                if not any(entry in param for param in self.json_dict[key][key2]):
                                    override_dict[key][key2].append(entry)
                                    prompt = True
                            except KeyError:
                                answer = True
                else:
                    override_dict[key] = []
                    for entry in curr_dict[key]:
                        for item in self.json_dict[key]:
                            if entry["name"] == item["name"]:
                                if any(entry[key] != item[key] for key in entry):
                                    override_dict[key].append(entry)
                                    prompt = True
                                break;
                        else:
                            # If the entry was not found, its a new parameter.
                            self.json_dict[key].append(entry)
                            answer = True
        return [override_dict,answer,prompt];

    def check_del(self,curr_dict):
        # Answer is true if a parameter's name cannot be found
        answer = False
        for key in self.json_dict:
            if key == "filesets":
                for key2 in self.json_dict[key]:
                    for i,entry in enumerate(self.json_dict[key][key2]):
                        if not any(entry == item for item in curr_dict[key][key2]):
                            del self.json_dict[key][key2][i]
                            answer = True
            else:
                for i,entry in enumerate(self.json_dict[key]):
                    if not any(entry["name"] == item["name"] for item in curr_dict[key]):
                        del self.json_dict[key][i]
                        answer = True
        return answer;

    # Grab the parameters from the GUI
    def get_params(self):
        # Dictionary of all unchanged edits
        save_dict = OrderedDict()
        # Begin grabbing all the info from the GUI
        for key in gui_func.json_format:
            save_dict[key] = self.page_dict[key].create_save_entry()
        return save_dict;

    # If a file was found, ask user if they want to replace it or create override
    def overwrite_prompt (self, **kwargs):
        # If there's no file named "ip_params.json" in the folder, return
        if not os.path.exists(self.module_path + "/" + gui_func.params_filename):
            return 1;
        popup = gtk.Dialog()                    # Create the popup dialog
        popup.add_buttons(*kwargs["buttons"])   # Add and label buttons

        label = gtk.Label(kwargs["text"])       # Add text to the dialog
        label.set_justify(gtk.JUSTIFY_CENTER)   # Set the text to the center
        # Create a little warning image
        img = gtk.Image()
        img.set_from_stock(gtk.STOCK_DIALOG_WARNING,gtk.ICON_SIZE_DIALOG)

        hbox = gtk.HBox()                       # Pack everything into a box
        hbox.pack_start(img)
        hbox.pack_start(label)
        popup.vbox.pack_start(hbox)
        yes = popup.run()                       # Wait for an answer
        popup.destroy()                         # Close the dialog
        return yes;

#------------------------------------------------------------------------------------
# Edit Parameters
#------------------------------------------------------------------------------------
    # Callback for adding items to scroll boxes
    def add_item (self, widget, *fields):
        widget_list = fields[0]["widget_list"]
        name = fields[0]["name"]
        new_item = self.read_add_boxes(widget_list)

        # If any fields are filled out, add them to the appropriate list
        if any(entry for entry in new_item):
            errors = gui_func.check_input(new_item,name,self.page_dict["params"].store,self.page_dict[name].store)
            if not errors:
                # Add the new item to the page's scroll box
                self.page_dict[name].store.append(new_item)
                self.clear_fields(widget,*fields)
            else:
                gui_func.update_log(self.log,errors)
                for i,widget in enumerate(widget_list):
                    if any(i in error["pos"] for error in errors):
                        gui_func.change_box_colors(widget,gui_func.error_color)
                    else:
                        gui_func.change_box_colors(widget,"black")

    # Grab the input from the add boxes
    def read_add_boxes (self, widget_list):
        new_item = []
        for widget in widget_list:
            try: new_item.append(widget.get_text())                     # Entry box
            except AttributeError:
                try: new_item.append(widget.get_child().get_text())     #ComboEntry
                except AttributeError:
                    for i,button in enumerate(widget.get_children()):   #Checkbuttons
                        new_item.append(button.get_active())
        return new_item

    # Callback to clear the parameter fields
    def clear_fields (self, widget, *fields):
        args = fields[0]["widget_list"]
        for entry in args:
            try: entry.set_text("")
            except AttributeError:
                try: entry.get_child().set_text("")
                except AttributeError:
                    for button in entry.get_children():
                        button.set_active(False)

    # Delete parameter row and remove it from all associated lists
    def delete_row (self, widget,event,model=None):
        if event.keyval == 65535:
            position = widget.get_selection().get_selected()[1]
            if position:
                # Check that its not a mandatory parameter
                if not any(self.page_dict["params"].store[position][0] == s for s in gui_func.mandatory_params):
                    name = self.page_dict["params"].store[position][0]
                    del self.page_dict["params"].store[position]

#------------------------------------------------------------------------------------
# Exiting functions
#------------------------------------------------------------------------------------
    def delete_event(self, widget, event, data=None):
        return False;

    def destroy(self, widget, data=None):
        gtk.main_quit()

#------------------------------------------------------------------------------------
# Create the GUI Class
#------------------------------------------------------------------------------------
if __name__ == "__main__":
    m = main_window()
