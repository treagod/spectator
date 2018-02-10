namespace HTTPInspector {
    
    class RequestHistoryItem : Gtk.FlowBoxChild {
        static string no_url = "<small><i>No URL specified</i></small>";
        Gtk.Box identifier { get; set;}
        Gtk.Label method;
        Gtk.Label request_name;
        Gtk.Label url;
        Gtk.Box box;
        public RequestItem item { get; set; }
        
        private string get_method_label(Method method) {
            var dark_theme = Gtk.Settings.get_default ().gtk_application_prefer_dark_theme;
            switch (method) {
                case Method.GET:
                    var color = dark_theme ? "64baff" : "0d52bf";
                    return "<span color=\"#" + color + "\">GET</span>";
                case Method.POST:
                    var color = dark_theme ? "9bdb4d" : "3a9104";
                    return "<span color=\"#" + color + "\">POST</span>";
                case Method.PUT:
                    var color = dark_theme ? "ffe16b" : "ad5f00";
                    return "<span color=\"#" + color + "\">PUT</span>";
                case Method.PATCH:
                    var color = dark_theme ? "ffa154" : "cc3b02";
                    return "<span color=\"#" + color + "\">PATCH</span>";
                case Method.DELETE:
                    var color = dark_theme ? "ed5353" : "a10705";
                    return "<span color=\"#" + color + "\">DELETE</span>";
                case Method.HEAD:
                    var color = dark_theme ? "ad65d6" : "4c158a";
                    return "<span color=\"#" + color + "\">HEAD</span>";
                default:
                    assert_not_reached ();
            }
        }
        
        public RequestHistoryItem (RequestItem it) {
            item = it;
            identifier = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            
            request_name = new Gtk.Label (item.name);
            request_name.halign = Gtk.Align.START;
            request_name.ellipsize = Pango.EllipsizeMode.END;
            
            url = new Gtk.Label ("");
            
            if (item.domain.length > 0) {
                url.label = "<small><i>" + item.domain + "</i></small>";
            } else {
                url.label = no_url;
            }
            
            url.halign = Gtk.Align.START;
            url.use_markup = true;
            url.ellipsize = Pango.EllipsizeMode.END;
            
            identifier.add (request_name);
            identifier.add (url);
            
            method = new Gtk.Label (get_method_label (item.method));
            method.set_justify (Gtk.Justification.CENTER);
            method.halign = Gtk.Align.END;
            method.margin_left = 10;
            method.margin_end = 10;
            method.use_markup = true;
            
            box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box.margin = 4;
                        
            box.pack_start (identifier, true, true, 0);
            box.pack_end (method, true, true, 2);
            
            add (box);
        }
        
        public void update (RequestItem it) {
            item = it;
            method.label = get_method_label (item.method);
            
            request_name.label = item.name;
            
            var escaped_url = escape_url (item.domain);       
            if (item.domain.length > 0) {
                url.label = "<small><i>" + escaped_url + "</i></small>";
            } else {
                url.label = no_url;
            }
            
            show_all ();
        }
        
        private string escape_url (string url) {
            var escaped_url = url;
            escaped_url = escaped_url.replace ("&", "&amp;");
            escaped_url = escaped_url.replace ("\"", "&quot;");
            escaped_url = escaped_url.replace ("<", "&lt;");
            escaped_url = escaped_url.replace (">", "&gt;");
            return escaped_url;
        }
    }
}
