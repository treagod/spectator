namespace HTTPInspector {
    public class UrlEntry : Gtk.Grid {
        private Gtk.ComboBoxText method_box;
        private Gtk.Entry url_entry;
        
        public signal void url_changed (string url);
        public signal void method_changed(Method method);
        public signal void request_activated ();

        public UrlEntry () {
            init_method_box ();
            init_url_entry ();
            margin_top = 4;
            margin_bottom = 4;
            url_entry.key_press_event.connect ((event) => {
                if (event.keyval == Gdk.Key.question) {
                    // Test if valid URL
                    // Add Parameter to url parameters
                    stdout.printf ("asd\n");
                }
                
                return false;
            });
            
            url_entry.changed.connect (() => {
                url_changed (url_entry.text);
            });
            
        }

        private void init_method_box () {
            method_box = new Gtk.ComboBoxText ();
            method_box.append_text ("GET");
            method_box.append_text ("POST");
            method_box.append_text ("PUT");
            method_box.append_text ("PATCH");
            method_box.append_text ("DELETE");
            method_box.append_text ("HEAD");
            method_box.active = 0;
            
            method_box.changed.connect (() => {
                var index = method_box.get_active ();
                method_changed (Method.convert(index));
            });

            add (method_box);
        }
        
        public void set_text (string url) {
            url_entry.text = url;
        }
        
        public void set_method (Method method) {
            method_box.active = method.to_i ();
        }
        
        public void item_status_changed (RequestStatus status) {
            switch (status) {
                case RequestStatus.SENT:
                    url_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "view-refresh-symbolic");
                    break;
                case RequestStatus.NOT_SENT:
                    url_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "media-playback-start-symbolic");
                    break;
                case RequestStatus.SENDING:
                    url_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "window-close-symbolic");
                    break;
            }
        }

        private void init_url_entry () {
            url_entry = new Gtk.Entry ();
            url_entry.placeholder_text = "Type an URL";
            url_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "media-playback-start-symbolic");

            url_entry.icon_press.connect (() => {
                widget_activate ();
            });

            url_entry.activate.connect (() => {
                widget_activate ();
            });
            url_entry.hexpand = true;
            add (url_entry);
        }
        
        private void widget_activate () {
            request_activated ();
        }
    }
}
