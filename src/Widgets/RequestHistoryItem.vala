namespace HTTPInspector {
    class RequestHistoryItem : Gtk.FlowBoxChild {
        Gtk.Label title { get; set;}
        Gtk.Label url;
        Gtk.Box box;
        
        private string get_method_label(int method) {
            if (method == 0) {
                return "<span color=\"#3892e0\">GET</span>";
            } else if (method == 1) {
                return "<span color=\"#3a9104\">POST</span>";
            } else if (method == 2) {
                return "<span color=\"#d48e15\">PUT</span>";
            } else if (method == 3) {
                return "<span color=\"#f37329\">PATCH</span>";
            } else if (method == 4) {
                return "<span color=\"#c6262e\">DELETE</span>";
            } else {
                return "";
            }
        }
        
        public RequestHistoryItem (string _title, string _url, int method) {
            title = new Gtk.Label (_title);
            title.halign = Gtk.Align.START;
            title.margin_end = 10;
            title.set_line_wrap (true);
            
            url = new Gtk.Label (get_method_label (method));
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
    }
}
