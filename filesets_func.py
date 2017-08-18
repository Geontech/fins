import pygtk
pygtk.require('2.0')
import gtk
from collections import OrderedDict
import gui_func
import os
import json

class filesets_page:
    def __init__ (self, path):
        self.store_dict = OrderedDict()     # Create OD for all fileset types
        self.path = path                    # Save off the path
        self.main_box = gtk.HBox()          # Create the main box
        self.create_dictionary()            # Fill out the OD

    def create_dictionary (self):
        # Create a liststore for every fileset type
        for string in gui_func.fileset_keys:
            self.store_dict[string] = gtk.ListStore(str)
        # Create a treeview for every fileset type (except for temp)
        for string in gui_func.fileset_keys[:-1]:
            frame = self.create_display(string)
            self.main_box.pack_start(frame,expand=True,fill=True,padding=2)
        # Fill out the temp entry
        for string in gui_func.temp:
            self.store_dict["temp"].append([string])

    # Creates the display for each individual tree
    def create_display (self, string):
        vbox = gtk.VBox()                           # Vertical box that holds all
        frame = gtk.Frame(string.title() + ":")     # Frame to hold tree and buttons
        scroll = gui_func.create_scroll_window()    # Scroll box to display tree

        # Create the tree with all the files
        tree = gui_func.create_tree(self.store_dict[string],[string],editable=False)
        scroll.add(tree)

        # Create the buttons for adding and deleting files
        add_button = gui_func.create_button("Add",
                                            self.add_row,
                                            stock=gtk.STOCK_ADD,
                                            string=string)

        del_button = gui_func.create_button("Delete",
                                            self.del_row,
                                            stock=gtk.STOCK_DELETE,
                                            string=string)

        # Pack the box
        vbox.pack_start(scroll,expand=True,fill=True,padding=5)
        button_box = gtk.HBox()
        button_box.pack_end(del_button,expand=False,fill=False,padding=2)
        button_box.pack_end(add_button,expand=False,fill=False,padding=2)
        vbox.pack_start(button_box,expand=False,fill=False,padding=0)
        frame.add(vbox)
        return frame;

    # Callback to add a fileset to a tree
    def add_row (self, widget, *args):
        # Figure out which tree we're in
        string = args[0]["string"]
        # Let user find their file in a chooser dialog
        fullname = gui_func.create_file_chooser("Add new " + string)
        # Check if user selected a file
        if fullname:
            # If yes, split the filename and the path
            pathname,filename = os.path.split(fullname)
        else:
            return;
        # Get the relative path between params file and the selected file
        relative_path = gui_func.get_relative_path(self.path,pathname)
        if relative_path != ".":
            relative_path      = "./" + relative_path + "/" + filename
        else:
            relative_path   = relative_path + "/" + filename
        self.store_dict[string].append([relative_path])

    # Callback to delete a row
    def del_row (self, widget, *args):
        # Figure out which tree we're in
        string = args[0]["string"]
        # Grab the frame number
        frame = gui_func.fileset_keys.index(string)
        # Loop through all the children until we get to the tree
        container = self.main_box
        for index in [frame,0,0,0]:
            container = container.get_children()[index]
        # Grab the selected entry from the tree
        position = container.get_selection().get_selected()[1]
        # If somethings selected, delete it
        if position:
            del self.store_dict[string][position]

    # Format the dictionary for saving
    def create_save_entry (self):
        save_dict = OrderedDict()
        for key in self.store_dict:
            save_dict[key] = []
            for row in self.store_dict[key]:
                save_dict[key].append(row[0])
        return save_dict;
