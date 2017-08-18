import pygtk
pygtk.require('2.0')
import gtk
from collections import OrderedDict
import gui_func
import os
import json

param_format = OrderedDict([("name",""),("parent","")])
ip_format   = OrderedDict([("name",""),("repo_name",""),("module_name",""),
                            ("vendor",""),("library",""),("params",[])])

class ip_page:
    def __init__ (self, ip, window, path,combo_store,log):
        self.store = []
        self.update_stored_ip(ip)
        self.window = window
        self.path = path
        # Create main box
        self.main_box = gtk.VBox()
        # Create dropdown menu
        self.main_box.pack_start(self.create_dropdown(),expand=False,fill=False,padding=10)
        # Create details box
        self.main_box.pack_start(self.create_details_box(combo_store,log),expand=True,fill=True,padding=0)
        # Create add new box
        self.main_box.show_all()

#------------------------------------------------------------------------------------
# Create dropdown menu for selecting IP entries
#------------------------------------------------------------------------------------
    def create_dropdown (self):
        # Save the selection box to the class for easier access
        self.selection_box = gtk.combo_box_new_text()

        # Add the names of each IP into the dropdown list
        for text in self.store:
            self.selection_box.append_text(text["name"])

        # Connect callback function
        self.selection_box.connect("changed",self.selection_changed)
        self.selection_box.show()
        self.selection_box.set_size_request(200,20)

        # Pack combobox and delete button into hbox at top of page
        hbox = gtk.HBox()
        hbox.pack_start(self.selection_box,expand=False,fill=False)

        # Button for deleting selected entry
        delete_button = gui_func.create_button("Delete IP",
                                                self.delete_ip,
                                                stock=gtk.STOCK_DELETE)

        hbox.pack_end(delete_button,expand=False,fill=False)
        return hbox;

    # Callback function for delete button
    def delete_ip (self, widget):
        clear_ip = {"name":"","repo_name":"","module_name":"","vendor":"","library":"","params":""}
        # Get rid of all staged changes
        self.reset_edited_ip(widget)
        # Retrieve all info input by the user
        param_details = self.grab_selected()
        if not param_details["name"]: return;
        # Index in the selection box and item list of the selected IP
        index = self.selection_box.get_active()
        # Remove the selected IP from the dropdown menu
        self.selection_box.remove_text(index)
        # Find and delete the selected IP
        i = self.store.index(param_details)
        self.store.remove(param_details)
        self.update_ip_display(clear_ip)
        return;

    # Get all the info from selected IP
    def grab_selected (self):
        param_details = OrderedDict()
        for i,key in enumerate(gui_func.ip_keys):
            try:
                param_details[key] = ""
                param_details[key] = self.details_box.get_children()[i].get_children()[0].get_text()
            except AttributeError:
                param_details[key] = []
                for entry in self.param_store:
                    param_details[key].append({"name":entry[0],"parent":entry[1]})
        return param_details;
#------------------------------------------------------------------------------------
# Create box for holding entries with IP Info
#------------------------------------------------------------------------------------

    def create_details_box (self,combo_store,log):
        # Vertical box that holds all important IP info
        self.details_box = gtk.VBox()
        # Create the entry boxes for user input and pack them into the box
        for string in ["Name:","Repo Name:","Module Name:","Vendor:","Library:"]:
            entry = gtk.Entry()
            frame = gui_func.create_label_widget(string,entry)
            self.details_box.pack_start(frame,expand=False,fill=False,padding=2)

        # Create scroll window for holding overridden parameters
        param_scroll = gui_func.create_scroll_window()
        self.param_store = gtk.ListStore(str,str)
        form = [0,combo_store]
        param_tree = gui_func.create_tree(self.param_store,["name","parent"],form=form,params=combo_store,log=log)
        param_scroll.add(param_tree)
        scroll_frame = gtk.Frame("Params:")
        scroll_frame.add(param_scroll)
        self.details_box.pack_start(scroll_frame,expand=True,fill=True,padding=0)
        # self.details_box.set_size_request(1050,600)

        # Buttons for saving, adding, and resetting IP info
        button_box = gtk.HBox()
        # Select an IP Params file and load it
        add_button = gui_func.create_button("Add IP",self.select_ip,stock=gtk.STOCK_ADD)
        button_box.pack_end(add_button,expand=False,fill=False,padding=0)

        # Save all changes made to the current IP
        save_button = gui_func.create_button("Save Changes",self.save_edited_ip,stock=gtk.STOCK_SAVE)
        button_box.pack_end(save_button,expand=False,fill=False,padding=0)

        # Reset all changes made to the current IP
        reset_button = gui_func.create_button("Reset Changes",self.reset_edited_ip,stock=gtk.STOCK_REVERT_TO_SAVED)
        button_box.pack_end(reset_button,expand=False,fill=False,padding=0)

        self.details_box.pack_start(button_box,expand=False,fill=False,padding=0)
        return self.details_box;

    # Function for selecting new IP file to include
    def select_ip (self,widget):
        fullname = gui_func.create_file_chooser("Select Sub-IP Params File",self.window,"*.json")
        if fullname:
            pathname,filename = os.path.split(fullname)
            with open(pathname + "/" + filename) as json_params_data:
                param_dict = json.load(json_params_data)
        else:
            return;

        param_details = OrderedDict([("name",""),("repo_name",""),("module_name",""),("vendor",""),("library",""),("params",[])])
        param_details["name"]           = gui_func.get_value(param_dict,"IP_NAME")

        # Get ip path
        if self.path != pathname + "/":
            relative_path = "./" + gui_func.get_relative_path(self.path,pathname)
        else:
            relative_path = "./"
        param_details["vendor"]         = gui_func.get_value(param_dict,"IP_COMPANY_URL")
        param_details["repo_name"]      = relative_path

        param_details["module_name"]    = " "
        param_details["library"]        = " "
        for param in param_dict["params"]:
            if not gui_func.mandatory(param["name"]):
                new_entry = OrderedDict([("name",param["name"]),("parent","")])
                param_details["params"].append(new_entry)
        self.selection_box.append_text(param_details["name"])
        self.store.append(param_details)
        self.selection_box.set_active(len(self.store)-1)
        self.save_edited_ip(widget)
        return;

    def save_edited_ip (self, widget):
        index = self.selection_box.get_active()
        self.store[index] = self.grab_selected()
        store_position = self.selection_box.get_active_iter()
        store = self.selection_box.get_model()
        store[store_position][0] = self.store[index]["name"]
        return;

    def reset_edited_ip (self, widget):
        index = self.selection_box.get_active()
        self.update_ip_display(self.store[index])

    def update_selections (self):
        self.selection_box.get_model().clear()
        for text in self.store:
            self.selection_box.append_text(text["name"])

    def selection_changed (self, widget):
        ip_name = widget.get_active_text()
        if ip_name == "Add New":
            self.update_ip_display(ip_format)
        else:
            index = widget.get_active()
            self.update_ip_display(self.store[index])
        return;

    def create_save_entry (self):
        return self.store;

    def update_ip_display (self,selected_param):
        for i,key in enumerate(gui_func.ip_keys):
            try: self.details_box.get_children()[i].get_children()[0].set_text(selected_param[key])
            except AttributeError:
                self.param_store.clear()
                for entry in selected_param[key]:
                    self.param_store.append([entry["name"],entry["parent"]])

    def update_stored_ip (self,ip):
        for entry in ip["ip"]:
            temp = OrderedDict()
            for key in gui_func.ip_keys:
                temp[key] = entry[key]
            self.store.append(temp)
