namespace HTTPInspector {
    
    
    public class RequestDialog : Gtk.Dialog {
        Gtk.Entry request_name_entry;
        
        public RequestDialog (Gtk.ApplicationWindow parent) {
            title = "New Request";
            border_width = 5;            
            set_size_request (350, 100);
            deletable = false;
            resizable = false;
            transient_for =  parent;
            modal = true;
            
            var request_name_label = new Gtk.Label (_("Name:"));
            request_name_entry = new Gtk.Entry ();
            request_name_entry.text = "My Request";
            
            Gtk.Box hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
            hbox.pack_start (request_name_label, false, true, 0);
            hbox.pack_start (request_name_entry, true, true, 0);
            
            add_button (_("Close"), Gtk.ResponseType.CLOSE);
            add_button (_("Create"), Gtk.ResponseType.APPLY);
            
            var content = get_content_area () as Gtk.Box;
            
            content.add (new DialogTitle ("Create Request"));
            content.add (hbox);
            
            response.connect ((source, id) => {
                switch (id) {
                case Gtk.ResponseType.APPLY:
                    var name = request_name_entry.text;
                    
                    if (name.length == 0) {
                        stdout.printf ("Needs a title\n");
                    } else {
                        stdout.printf ("Created request\n");
                        destroy ();
                    }
                    
                    break;
                case Gtk.ResponseType.CLOSE:
                    destroy ();
                    break;
                }
            });
        }
        
        private class DialogTitle : Gtk.Box {
            private Gtk.Image icon;
            private Gtk.Label label;
            
            public DialogTitle (string text) {
                icon = new Gtk.Image.from_icon_name ("find-location", Gtk.IconSize.DIALOG);
                label = new Gtk.Label ("<b>" + text + "</b>");
                label.use_markup = true;
                label.margin_bottom = 10;
                label.xalign = 0;
                label.get_style_context ().add_class ("h2");
                
                pack_start (icon, false, true, 0);
                pack_start (label, true, true, 0);
                
                margin_bottom = 10;
            }
        }
    }
}
