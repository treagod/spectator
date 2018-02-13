namespace HTTPInspector {
    class ResponseView : Gtk.Box {
        private Gtk.ScrolledWindow scrolled;
        private ResponseText response;
        private ResponseStatusBar status_bar;
        
        private const string CSS = """
            .status-box {
                border-width: 1px;
                border-style: solid;
                border-color: #3a9104;
                color: #3a9104;
                background-color: #fafafa;
            }
            
            .response-info-box {
                border-width: 1px;
                border-style: solid;
                border-color: #273445;
                color: #273445 ;
                background-color: #fafafa;
            }
        """;
        
        static construct {
            var provider = new Gtk.CssProvider ();
            try {
                provider.load_from_data (CSS, CSS.length);
                Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (Error e) {
                critical (e.message);
            }
        }
        
        construct {
            orientation = Gtk.Orientation.VERTICAL;
            /*
            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            
            var status_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
            var label = new Gtk.Label ("200 Ok");
            label.margin = 5;
            status_box.pack_start (label, false, false);
            box.pack_start (status_box, false, false);
            status_box.margin_left = 15;
            status_box.get_style_context ().add_class ("status-box");
            
            var status_box2 = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
            var label2 = new Gtk.Label ("Time 13.2 s");
            label2.margin = 5;
            status_box2.pack_start (label2, false, false);
            status_box2.get_style_context ().add_class ("response-info-box");
            
            var status_box3 = new Gtk.Box (Gtk.Orientation.HORIZONTAL,9);
            var label3 = new Gtk.Label ("Size 11.6 KB");
            label3.margin = 5;
            status_box3.pack_start (label3, false, false);
            status_box3.get_style_context ().add_class ("response-info-box");
            
            box.pack_start (status_box2, false, false);
            box.pack_start (status_box3, false, false);
            
            box.spacing = 7;
            */
            
            status_bar = new ResponseStatusBar ();
            
            pack_start (status_bar, false, false, 15);
        }
        
        public ResponseView () {
            scrolled = new Gtk.ScrolledWindow (null, null);
            response = new ResponseText ();
            
            
            scrolled.add (response);
            
            pack_start (scrolled);
        }
        
        public void update_response (ResponseItem? it) {
            response.insert (it);
            status_bar.update (it);
        }
        
        public void reset () {
            response = new ResponseText ();
        }
    }
}
