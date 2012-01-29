/*-
 * Copyright (c) 2011	   Scott Ringwelski <sgringwe@mtu.edu>
 *
 * Originally Written by Scott Ringwelski for BeatBox Music Player
 * BeatBox Music Player: http://www.launchpad.net/beat-box
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

using Gtk;
using Gdk;
using Gee;

public class BeatBox.SimpleOptionChooser : EventBox {
	Gtk.Menu menu;
	LinkedList<CheckMenuItem> items;
	Gtk.Image enabled;
	Gtk.Image disabled;

	// Margin added at each side of the icon
	private const int BORDER_WIDTH = 3; //px

	int clicked_index;
	int previous_index; // for left click
	bool toggling;

	public signal void option_changed(int index);

	public SimpleOptionChooser.from_pixbuf (Pixbuf enabled, Pixbuf disabled) {
		this.enabled = new Image.from_pixbuf (enabled);
		this.disabled = new Image.from_pixbuf (disabled);

		initialize ();
	}

	public SimpleOptionChooser.from_image (Gtk.Image enabled, Gtk.Image disabled) {
		this.enabled = enabled;
		this.disabled = disabled;

		initialize ();
	}

	private void initialize () {
		menu = new Gtk.Menu();
		items = new LinkedList<CheckMenuItem>();
		toggling = false;

		clicked_index = 0;
		previous_index = 0;

		int enabled_size = enabled.get_pixel_size ();
		int disabled_size = disabled.get_pixel_size ();
		int size = (enabled_size > disabled_size) ? enabled_size : disabled_size;

		width_request = size + BORDER_WIDTH;
		height_request = width_request;

		// make the event box transparent
		set_above_child(true);
		set_visible_window(false);

		button_press_event.connect(buttonPress);

		set_image ();
	}

	public void setOption(int index) {
		if(index >= items.size)
			return;

		for(int i = 0;i < items.size; ++i) {
			if(i == index)
				items.get(i).set_active(true);
			else
				items.get(i).set_active(false);
		}

		clicked_index = index;
		option_changed(index);

		set_image ();
	}

	public int appendItem(string text) {
		var item = new CheckMenuItem.with_label(text);
		items.add(item);
		menu.append(item);

		item.toggled.connect( () => {
			if(!toggling) {
				toggling = true;

				if(clicked_index != items.index_of(item))
					setOption(items.index_of(item));
				else
					setOption(0);

				toggling = false;
			}
		});

		item.show();
		previous_index = items.size - 1; // my lazy way of making sure the bottom item is the default on/off on click

		return items.size - 1;
	}

	public virtual bool buttonPress(Gdk.EventButton event) {
		if(event.type == Gdk.EventType.BUTTON_PRESS && event.button == 1) {
			if(clicked_index == 0)
				setOption(previous_index);
			else {
				previous_index = clicked_index;
				setOption(0);
			}
		}
		else if(event.type == Gdk.EventType.BUTTON_PRESS && event.button == 3) {
			menu.popup (null, null, null, 3, get_current_event_time());
		}

		return false;
	}

	public void set_image () {
		if (get_child () != null)
			remove (get_child ());

		if (clicked_index != 0)
			add (enabled);
		else
			add (disabled);

		show_all ();
	}
}

