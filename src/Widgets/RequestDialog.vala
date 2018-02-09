namespace HTTPInspector {
    
    
    public class RequestDialog : Gtk.Dialog {
        Gtk.Entry request_name_entry;
        Gtk.ComboBoxText method_box;
        public signal void creation(RequestItem item);
        
        public RequestDialog (Gtk.ApplicationWindow parent) {
            title = "New Request";
            border_width = 5;            
            set_size_request (425, 100);
            deletable = false;
            resizable = false;
            transient_for =  parent;
            modal = true;
            
            var request_name_label = new Gtk.Label (_("Name:"));
            request_name_entry = new Gtk.Entry ();
            request_name_entry.text = "My Request";
            
            method_box = new Gtk.ComboBoxText ();
            method_box.append_text ("GET");
            method_box.append_text ("POST");
            method_box.append_text ("PUT");
            method_box.append_text ("PATCH");
            method_box.append_text ("DELETE");
            method_box.append_text ("HEAD");
            method_box.active = 0;
            
            Gtk.Box hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 15);
            hbox.pack_start (request_name_label, false, true, 0);
            hbox.pack_start (request_name_entry, true, true, 0);
            hbox.pack_end (method_box, false, true, 0);
            hbox.margin_bottom = 20;
            
            add_button (_("Close"), Gtk.ResponseType.CLOSE);
            add_button (_("Create"), Gtk.ResponseType.APPLY);
            var content = get_content_area () as Gtk.Box;
            
            content.add (new DialogTitle ("Create Request"));
            content.add (hbox);
            content.margin = 15;
            content.margin_top = 0;
            
            request_name_entry.activate.connect (() => {
                create_request ();
            });
            
            response.connect ((source, id) => {
                switch (id) {
                case Gtk.ResponseType.APPLY:
                    create_request ();
                    
                    break;
                case Gtk.ResponseType.CLOSE:
                    destroy ();
                    break;
                }
            });
        }
        
        private void create_request () {
            var content = get_content_area () as Gtk.Box;
            var name = request_name_entry.text;
            
            if (name.length == 0) {
                var warning_label = new Gtk.Label ("<span color=\"#a10705\">" + _("Request name must not be empty.") + "</span>");
                warning_label.use_markup = true;
                warning_label.margin = 5;
                content.pack_start (warning_label, false, true, 0);
                show_all ();  
                request_name_entry.get_style_context ().add_class ("error");
            } else {
                var index = method_box.get_active ();
                creation (new RequestItem (name, Method.convert(index)));
                destroy ();
            }
        }
        
        private class DialogTitle : Gtk.Box {
            private Gtk.Image icon;
            private Gtk.Label label;
            
            public DialogTitle (string text) {
                icon = new Gtk.Image.from_icon_name ("find-location", Gtk.IconSize.DIALOG);
                label = new Gtk.Label ("<b>" + text + "</b>");
                label.use_markup = true;
                label.margin_left = 10;
                label.margin_bottom = 10;
                label.xalign = 0;
                label.get_style_context ().add_class ("h2");
                
                pack_start (icon, false, true, 0);
                pack_start (label, true, true, 0);
                
                margin_bottom = 15;
            }
        }
    }
}
