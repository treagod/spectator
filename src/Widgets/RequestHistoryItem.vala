namespace HTTPInspector {
    class RequestHistoryItem : Gtk.FlowBoxChild {
        Gtk.Label title { get; set;}
        Gtk.Label url;
        Gtk.Box box;
        public RequestItem item { get; set; }
        
        private string get_method_label(Method method) {
            switch (method) {
                case Method.GET:
                    return "<span color=\"#3892e0\">GET</span>";
                case Method.POST:
                    return "<span color=\"#3a9104\">POST</span>";
                case Method.PUT:
                    return "<span color=\"#d48e15\">PUT</span>";
                case Method.PATCH:
                    return "<span color=\"#f37329\">PATCH</span>";
                case Method.DELETE:
                    return "<span color=\"#c6262e\">DELETE</span>";
                case Method.HEAD:
                    return "<span color=\"#3892e0\">HEAD</span>";
                default:
                    assert_not_reached ();
            }
        }
        
        public RequestHistoryItem (RequestItem it) {
            item = it;
            title = new Gtk.Label (item.name);
            title.halign = Gtk.Align.START;
            title.margin_end = 10;
            title.set_line_wrap (true);
            
            url = new Gtk.Label (get_method_label (item.method));
            url.set_justify (Gtk.Justification.CENTER);
            url.halign = Gtk.Align.END;
            url.margin_end = 10;
            url.set_line_wrap (true);
            url.use_markup = true;
            
            box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box.margin = 4;
                        
            box.pack_start (title, true, true, 0);
            box.pack_end (url, true, true, 2);
            
            add (box);
        }
        
        public void update (RequestItem it) {
            item = it;
            url.label = get_method_label (item.method);
        }
    }
}
