namespace HTTPInspector {
    class HeaderView : Gtk.Box {
        private List<Gtk.Button> buttons;
        public Gee.ArrayList<HeaderField> headers;
        private Gtk.Grid header_fields;
        private RequestItem item;

        public HeaderView () {
            orientation = Gtk.Orientation.VERTICAL;
            margin_left = 7;
            margin_right = 7;

            header_fields = new Gtk.Grid ();
            buttons = new List<Gtk.Button> ();
            headers = new Gee.ArrayList<HeaderField> ();
            header_fields.column_spacing = 3;
            header_fields.row_spacing = 3;
            var add_row_button = new Gtk.Button.with_label ("Add header");

            add_row_button.margin_top = 7;
            add_row_button.margin_left = 128;
            add_row_button.margin_right = 128;

            add_row_button.clicked.connect (() => {
                add_row ();
            });


            add (header_fields);
            add (add_row_button);
        }
        
        public void update_item (RequestItem it) {
            item = it;
            
            if (item.headers.size == 0) {
                item.add_header ("", "");
            }
            
            int i = 0;
            foreach (var header in item.headers) {
                add_header_row (header, i);
                i++;
            }
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
            var header_field = new HeaderField (0);      
            var del_button = new Gtk.Button.from_icon_name ("window-close");

            queue_button (del_button);
            
            headers.add (header_field);

            header_fields.attach (header_field, 0, (int) buttons.length (), 1, 1);
            header_fields.attach (del_button, 2, (int) buttons.length (), 1, 1);
            show_all ();
        }
        
        public void add_header_row (Header header, int index) {
            var header_field = new HeaderField (index);
            header_field.set_header (header.key, header.val); 
            var del_button = new Gtk.Button.from_icon_name ("window-close");
            
            item.add_header (header.key, header.val);

            queue_button (del_button);
            
            headers.add (header_field);

            header_fields.attach (header_field, 0, (int) buttons.length (), 1, 1);
            header_fields.attach (del_button, 2, (int) buttons.length (), 1, 1);
            show_all ();
        }
    }
}
