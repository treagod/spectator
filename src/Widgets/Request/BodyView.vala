/*
* Copyright (c) 2018 Marvin Ahlgrimm (https://github.com/treagod)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marvin Ahlgrimm <marv.ahlgrimm@gmail.com>
*/

namespace Spectator.Widgets.Request {
    class BodyView : Gtk.Box {
        private Gtk.Stack body_content;
        public Gtk.ComboBoxText body_type_box;
        private Gtk.ComboBoxText language_box;
        private Gtk.Box body_content_type_selections;
        private KeyValueList form_data;
        private KeyValueList urlencoded;
        private Gtk.ScrolledWindow raw_body;
        private bool ignore_signal;

        public signal void type_changed (RequestBody.ContentType type);
        public signal void body_buffer_changed (string content);
        public signal void content_changed (string content);

        public signal void key_value_added (Pair item);
        public signal void key_value_removed (Pair item);
        public signal void key_value_updated (Pair item);

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 2;
        }

        public BodyView () {
            body_content = new Gtk.Stack ();
            body_content.hexpand = true;
            this.ignore_signal = true;

            setup_body_type_box ();
            setup_language_box ();
            setup_body_type_behaviour ();
            setup_form_data ();
            setup_urlencoded ();
            setup_raw_body ();

            body_content.set_visible_child (form_data);
            add (body_content);
            this.ignore_signal = false;
        }

        private void setup_language_box () {
            language_box = new Gtk.ComboBoxText ();
            language_box.append_text (_("Plain"));
            language_box.append_text (_("XML"));
            language_box.append_text (_("JSON"));
            language_box.append_text (_("HTML"));
            language_box.active = 0;

            language_box.changed.connect (() => {
                var index = language_box.get_active ();
                var source_view = (BodySourceView) raw_body.get_child ();

                switch (index) {
                    case 1:
                    source_view.set_lang ("xml");
                    break;
                    case 2:
                    source_view.set_lang ("json");
                    break;
                    case 3:
                    source_view.set_lang ("html");
                    break;
                    default:
                    source_view.set_lang ("plain");
                    break;
                }

                if (!this.ignore_signal) send_language_box_signal (index);
            });
        }

        private void send_language_box_signal (int idx) {
            switch (idx) {
                case 1:
                type_changed (RequestBody.ContentType.XML);
                break;
                case 2:
                type_changed (RequestBody.ContentType.JSON);
                break;
                case 3:
                type_changed (RequestBody.ContentType.HTML);
                break;
                default:
                type_changed (RequestBody.ContentType.PLAIN);
                break;
            }
        }

        private void setup_body_type_box () {
            body_type_box = new Gtk.ComboBoxText ();
            body_type_box.append_text ("Form Data");
            body_type_box.append_text ("Urlencoded");
            body_type_box.append_text ("Text");
        }

        private void setup_body_type_behaviour () {
            body_content_type_selections = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
            body_content_type_selections.margin_bottom = 12;
            body_content_type_selections.halign = Gtk.Align.START;

            body_type_box.changed.connect (() => {
                var index = body_type_box.get_active ();
                body_content_type_selections.remove (language_box);

                switch (index) {
                    case 0:
                    body_content.set_visible_child (form_data);
                    if (!this.ignore_signal) type_changed (RequestBody.ContentType.FORM_DATA);
                    break;
                    case 1:
                    body_content.set_visible_child (urlencoded);
                    if (!this.ignore_signal) type_changed (RequestBody.ContentType.URLENCODED);
                    break;
                    case 2:
                    body_content_type_selections.pack_end (language_box);
                    body_content_type_selections.reorder_child (language_box, 0);
                    body_content.set_visible_child (raw_body);
                    if (!this.ignore_signal) send_language_box_signal (language_box.active);
                    break;
                    default:
                    assert_not_reached ();
                }
                body_content_type_selections.show_all ();
            });

            body_content_type_selections.pack_start (body_type_box, false, true);

            add (body_content_type_selections);
        }

        private string serialize_key_value_content (Gee.ArrayList<Pair> pairs) {
            var form_data_builder = new StringBuilder ();
            foreach (var entry in pairs) {
                form_data_builder.append ("%s>>|<<%s\n".printf (entry.key, entry.val));
            }
            return form_data_builder.str;
        }

        // TODO: refactor to model method
        private Gee.ArrayList<Pair> deserialize_key_value_content (string content) {
            var pairs = new Gee.ArrayList<Pair> ();
            var pair_strings = content.split("\n");

            foreach (var pair in pair_strings) {
                if (pair.strip ().length > 0) {
                    var key_value = pair.split(">>|<<");
                    pairs.add (new Pair(key_value[0], key_value[1]));
                }
            }

            return pairs;
        }

        public void set_content (string content, RequestBody.ContentType type) {
            this.ignore_signal = true;
            this.set_body_type (type);

            if (type == RequestBody.ContentType.FORM_DATA) {
                this.form_data.change_rows (this.deserialize_key_value_content (content));
                this.form_data.show_all ();
            } else if (type == RequestBody.ContentType.URLENCODED) {
                /* TODO: Do we need two different lists? */
                this.urlencoded.change_rows (this.deserialize_key_value_content (content));
            } else {
                var source_view = (BodySourceView) raw_body.get_child ();
                source_view.set_content (content);
            }
            this.ignore_signal = false;
        }

        public void reset_content () {
            this.ignore_signal = true;
            this.form_data.clear ();
            this.urlencoded.clear ();
            var source_view = (BodySourceView) raw_body.get_child ();
            source_view.set_content ("");
            this.ignore_signal = false;
        }

        private void setup_form_data () {
            form_data = new KeyValueList (_("Add"));

            form_data.item_added.connect (() => {
                this.content_changed (serialize_key_value_content (form_data.get_all_items ()));
            });

            form_data.item_updated.connect ((item) => {
                this.content_changed (serialize_key_value_content (form_data.get_all_items ()));
            });

            form_data.item_deleted.connect ((item) => {
                this.content_changed (serialize_key_value_content (form_data.get_all_items ()));
            });

            body_content.add (form_data);
        }

        private void setup_urlencoded () {
            urlencoded = new KeyValueList (_("Add"));

            urlencoded.item_added.connect ((item) => {
                this.content_changed (serialize_key_value_content (urlencoded.get_all_items ()));
            });

            urlencoded.item_updated.connect ((item) => {
                this.content_changed (serialize_key_value_content (urlencoded.get_all_items ()));
            });

            urlencoded.item_deleted.connect ((item) => {
                this.content_changed (serialize_key_value_content (urlencoded.get_all_items ()));
            });

            body_content.add (urlencoded);
        }

        private void setup_raw_body () {
            raw_body = new Gtk.ScrolledWindow (null, null);
            raw_body.vexpand = true;
            var raw_body_source_view = new BodySourceView ();
            raw_body_source_view.body_buffer_changed.connect ((content) => {
                this.content_changed (content);
            });
            raw_body.add (raw_body_source_view);
            body_content.add (raw_body);
        }

        public void set_body_type (RequestBody.ContentType type) {
            switch (type) {
                case RequestBody.ContentType.FORM_DATA:
                    body_type_box.active = 0;
                    break;
                case RequestBody.ContentType.URLENCODED:
                    body_type_box.active = 1;
                    break;
                case RequestBody.ContentType.PLAIN:
                    body_type_box.active = 2;
                    language_box.active = 0;
                    break;
                case RequestBody.ContentType.JSON:
                    body_type_box.active = 2;
                    language_box.active = 2;
                    break;
                case RequestBody.ContentType.XML:
                    body_type_box.active = 2;
                    language_box.active = 1;
                    break;
                case RequestBody.ContentType.HTML:
                    body_type_box.active = 2;
                    language_box.active = 3;
                    break;
                default:
                    assert_not_reached ();
            }
        }
    }
}
