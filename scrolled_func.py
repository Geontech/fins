#====================================================================================
# Company:      Geon Technologies, LLC
# File:         streams_func.py
# Description:  Python script used to handle Params, Streams, and registers
#               page in the fins gui
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

class scrolled_page:
    def __init__ (self,json_dict,arg_dict,key,button_funcs,textview,combo_store=None):
        # Determines which page this is (params, streams, or registers)
        self.key = key
        # Create the scroll window
        self.scroll = gui_func.create_scroll_window()
        # Grab the column specifiers
        cols        = self.create_col_list(arg_dict["forms"])
        # Create a list store model with all our info
        self.store  = gui_func.create_model(json_dict[self.key],cols)
        # Name the store for easy identification later
        self.store.set_name(key)
        # If no functions passed in, set entry to none
        if not "func" in arg_dict: arg_dict["func"] = None
        # If a store was provided for the combo entries, use that for any 1's in form
        if combo_store:
            for i,entry in enumerate(arg_dict["forms"]):
                if entry == 1:
                    arg_dict["forms"][i] = combo_store
            self.tree = gui_func.create_tree(self.store,self.key,
                                                form=arg_dict["forms"],
                                                connect_func=arg_dict["func"],
                                                params=combo_store,
                                                log=textview)
        # Otherwise, assume all models for combo entries were passed in
        else:
            self.tree = gui_func.create_tree(self.store,self.key,
                                                form=arg_dict["forms"],
                                                connect_func=arg_dict["func"],
                                                params=self.store,
                                                log=textview)

        # Don't allow sorting by header (it disables user reordering it)
        self.tree.set_headers_clickable(False)
        # Put the tree into the scroll box
        self.scroll.add(self.tree)

        # self.scroll.set_size_request(1050,500)
        self.main_box = gtk.HBox()
        self.main_box.pack_start(self.scroll)
        # Create box for adding a new parameter
        frame = self.create_add_boxes(arg_dict["forms"],button_funcs,combo_store)
        temp = gtk.VBox()
        temp.pack_start(frame,expand=False,fill=False,padding=10)
        self.main_box.pack_start(temp,expand=False,fill=False,padding=5)
        return;

    # Read the model list and create the appropriate liststore
    def create_col_list(self,form):
        cols = []
        for item in form:
            # If 2, its a check box and needs a boolean
            if item == 2:
                cols.append(bool)
            # Otherwise, entries and comboentries use strings
            else:
                cols.append(str)
        return cols;

    # Format everything to be saved
    def create_save_entry(self):
        # List object to be returned
        save_entry = []
        # For each entry in the page's store (list store or list)
        for row in self.store:
            param = OrderedDict()
            for i,string in enumerate(gui_func.key_dict[self.key]):
                # Used in needs to be handled differently
                if string == "used_in": break
                # If the value is a list, it can't stay a string
                elif row[i].startswith("[") and row[i].endswith("]"):
                    for i in (["[","]",","]):
                        new_row = row[i].replace(i,"")
                    new_list = new_row.split()
                    for i in range(len(new_list)):
                        try:
                            new_list[i] = int(new_list[i])
                        except ValueError:  pass    # Probably a parameter
                    param[string] = new_list
                else:
                    # Grab each entry in the list store
                    param[string] = row[i]
            # Only params uses check boxes
            if self.key == "params":
                param["used_in"] = []
                for i,string in enumerate(["hdl","mat","tcl"]):
                    # Check if check box is active or not
                    if row[i+3]:
                        param["used_in"].append(string)
            save_entry.append(param)
        return save_entry;

    # Changes font color of a widget and its frame
    def change_font (self,widget):
        if type(widget) == type(gtk.Entry()):
            widget.modify_text(widget.get_state(),gtk.gdk.color_parse("black"))
        else:
            widget.get_child().modify_text(widget.get_state(),gtk.gdk.color_parse("black"))
        parent = widget.get_parent().get_children()[1]
        parent.modify_fg(parent.get_state(),gtk.gdk.color_parse("black"))

    # Creates the box that allows users to add an entry
    def create_add_boxes (self,widgets,funcs,combo_store):
        vbox = gtk.VBox()
        widget_list = []
        # Initial list widgets for the frame
        key_list = gui_func.key_dict[self.key]
        for i,key in enumerate(key_list):
            key = key.title()       # Capitalize first lett
            if widgets[i] == 0:
                widget_list.append(gtk.Entry())
                widget_list[-1].connect("changed",self.change_font)
            elif widgets[i] == 2:
                temp = gtk.HBox()
                for string in ["hdl","mat","tcl"]:
                    check_button = gtk.CheckButton(string)
                    temp.pack_start(check_button,expand=False,fill=False)
                widget_list.append(temp)
            else:
                if widgets[i] == 1:
                    widget_list.append(gtk.ComboBoxEntry(combo_store,column=0))
                else:
                    widget_list.append(gtk.ComboBoxEntry(widgets[i],column=0))
                widget_list[-1].connect("changed",self.change_font)

            frame = gui_func.create_label_widget(key+":",widget_list[-1])
            frame.set_property("shadow-type",gtk.SHADOW_NONE)
            vbox.pack_start(frame,expand=False,fill=False)

        # Create the labels for the add and clear buttons
        text=["New " + self.key.title(),"Clear " + self.key.title()]
        # List of stock icons for the buttons
        stock = [gtk.STOCK_ADD,gtk.STOCK_NEW]
        button_box = gtk.HBox()
        for i,function in enumerate(funcs):
            # Create the buttons for adding and clearing parameters
            button = gui_func.create_button(text=text[i],connect_func=function,
                                            stock=stock[i],widget_list=widget_list,name=self.key)
            button_box.pack_start(button,expand=True,fill=True,padding=0)
        vbox.pack_start(button_box,expand=False,fill=True,padding=0)
        # Create main frame for adding
        add_frame = gtk.Frame("Add New " + self.key.title())

        add_frame.set_property("label-yalign",0.0)
        # add_frame.set_property("shadow-type",gtk.SHADOW_NONE)
        event = gtk.EventBox()
        color_map = event.get_colormap()
        color = color_map.alloc_color("grey90")
        style = event.get_style().copy()
        style.bg[gtk.STATE_NORMAL] = color
        event.set_style(style)
        add_frame.add(vbox)
        event.add(add_frame)
        return event;
