# Slideshow Shuffle Plugin for Eye of GNOME
# Copyright (C) 2008  Johannes Marbach <jm@rapidrabbit.de>
#
# 2023 - Some changes done by Fynn Freyer <fynn.freyer@googlemail.com>
#
# Original can be found here:
# https://gitlab.gnome.org/GNOME/eog-plugins/-/tree/master/plugins/slideshowshuffle
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

from gi.repository import GObject, Eog
from random import seed, shuffle


class SlideshowShufflePlugin(GObject.Object, Eog.WindowActivatable):
    # Override EogWindowActivatable's window property
    window = GObject.property(type=Eog.Window)

    def __init__(self):
        GObject.Object.__init__(self)

    def do_activate(self):
        seed()
        self.slideshow = False
        self.state_handler_id = self.window.connect(
            'window-state-event',
            self.state_changed_cb,
            self
        )

    def do_deactivate(self):
        self.window.disconnect(self.state_handler_id)

    # The callback functions are done statically to avoid causing additional
    # references on the window property causing eog to not quit correctly.
    @staticmethod
    def state_changed_cb(window, event, self):
        mode = self.window.get_mode()
        store = window.get_store()

        if mode == Eog.WindowMode.SLIDESHOW and not self.slideshow:
            print("slide")
            # Slideshow starts
            self.slideshow = True

            # Query position of current image
            img = window.get_image()
            if img:
                pos = store.get_pos_by_image(img)
            else:
                pos = 0

            # Generate random map
            uris = [
                row[2].get_uri_for_display()
                for i, row in enumerate(store)
            ]

            prev_start = uris[0]
            new_start = uris[pos]

            order = [i for i in range(len(uris)) if i not in {0, pos}]
            new_order = order[:]
            shuffle(new_order)

            self.order_map = {
                uris[old_i]: new_i
                for old_i, new_i in zip(order, new_order)
                if old_i != 0
            }

            self.order_map[new_start] = 0
            self.order_map[prev_start] = pos

            # Put random sort function in place
            new_order.insert(pos, 0)
            if pos != 0:
                new_order.insert(0, pos)

            store.set_default_sort_func(self.random_sort_function, self)
            store.reorder(new_order)

        elif mode == Eog.WindowMode.NORMAL and self.slideshow:
            # Slideshow ends
            self.slideshow = False

            # Put alphabetic sort function in place
            store.set_default_sort_func(self.alphabetic_sort_function)

    @staticmethod
    def random_sort_function(store, iter1, iter2, self):
        uri1 = store[iter1][2].get_uri_for_display()
        uri2 = store[iter2][2].get_uri_for_display()

        try:
            pos1 = self.order_map[uri1]
            pos2 = self.order_map[uri2]
        except KeyError as e:
            # TODO: not nice
            exit(f"KeyError: {e}")

        if pos1 > pos2:
            return 1
        elif pos1 < pos2:
            return -1
        else:
            return 0

    @staticmethod
    def alphabetic_sort_function(store, iter1, iter2, data=None):
        uri1 = store[iter1][2].get_uri_for_display()
        uri2 = store[iter2][2].get_uri_for_display()

        if uri1 > uri2:
            return 1
        elif uri1 < uri2:
            return -1
        else:
            return 0
