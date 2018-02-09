namespace HTTPInspector {
    class HeaderView : Gtk.Box {
        List<Gtk.Button> buttons;
        Gtk.Grid header_fields;

        public HeaderView () {
            orientation = Gtk.Orientation.VERTICAL;
            margin_left = 7;
            margin_right = 7;

            header_fields = new Gtk.Grid ();
            header_fields.attach (new Gtk.Label("Header Key"), 0, 0, 1, 1);
            header_fields.attach (new Gtk.Label("Header Value"), 1, 0, 1, 1);
            buttons = new List<Gtk.Button> ();
            header_fields.column_spacing = 3;
            header_fields.row_spacing = 3;
            var add_row_button = new Gtk.Button.with_label ("Add header");

            add_row_button.margin_top = 7;
            add_row_button.margin_left = 128;
            add_row_button.margin_right = 128;

            add_row_button.clicked.connect (() => {
                add_row ();
            });

            add_row ();


            add (header_fields);
            add (add_row_button);
        }

        private void queue_button (Gtk.Button button) {
            buttons.append (button);
            button.clicked.connect (() => {
                var index = buttons.index (button);
                buttons.remove (button);
                header_fields.remove_row (index + 1);

                if (buttons.length () == 0) {
                    add_row ();
                }
            });
        }

        public void add_row () {
            var header_key = new Gtk.Entry ();
            var header_value = new Gtk.Entry ();
            var del_button = new Gtk.Button.from_icon_name ("window-close");

            header_key.hexpand = true;
            header_value.hexpand = true;

            queue_button (del_button);

            header_fields.attach (header_key, 0, (int) buttons.length (), 1, 1);
            header_fields.attach (header_value, 1, (int) buttons.length (), 1, 1);
            header_fields.attach (del_button, 2, (int) buttons.length (), 1, 1);
            show_all ();
        }
    }
}
