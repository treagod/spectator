namespace HTTPInspector {
    class HeaderField : Gtk.Box {
        private Gtk.Entry header_key_field;
        private Gtk.Entry header_value_field;
        
        public string key { get { return header_key_field.text; }}
        public string val { get { return header_value_field.text; }}
        
        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
        }
        
        public HeaderField () {
            header_key_field = new Gtk.Entry ();
            header_value_field = new Gtk.Entry ();
            
            header_key_field.hexpand = true;
            header_value_field.hexpand = true;
            
            header_key_field.set_completion (common_header_key_completion ());
            
            add (header_key_field);
            add (header_value_field);
        }
        
        private Gtk.EntryCompletion common_header_key_completion () {
            Gtk.EntryCompletion completion = new Gtk.EntryCompletion ();

            // Create, fill & register a ListStore:
            Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
            completion.set_model (list_store);
            completion.set_text_column (0);
            Gtk.TreeIter iter;

            list_store.append (out iter);
            list_store.set (iter, 0, "Accept");
            list_store.append (out iter);
            list_store.set (iter, 0, "Accept-Charset");
            list_store.append (out iter);
            list_store.set (iter, 0, "Accept-Encoding");
            list_store.append (out iter);
            list_store.set (iter, 0, "Accept-Language");
            list_store.append (out iter);
            list_store.set (iter, 0, "Authorization");
            list_store.append (out iter);
            list_store.set (iter, 0, "Cache-Control");
            list_store.append (out iter);
            list_store.set (iter, 0, "Connection");
            list_store.append (out iter);
            list_store.set (iter, 0, "Cookie");
            list_store.append (out iter);
            list_store.set (iter, 0, "Content-Length");
            list_store.append (out iter);
            list_store.set (iter, 0, "Content-MD5");
            list_store.append (out iter);
            list_store.set (iter, 0, "Content-Type");
            list_store.append (out iter);
            list_store.set (iter, 0, "Date");
            list_store.append (out iter);
            list_store.set (iter, 0, "Expect");
            list_store.append (out iter);
            list_store.set (iter, 0, "Forwarded");
            list_store.append (out iter);
            list_store.set (iter, 0, "From");
            list_store.append (out iter);
            list_store.set (iter, 0, "Host");
            list_store.append (out iter);
            list_store.set (iter, 0, "If-Match");
            list_store.append (out iter);
            list_store.set (iter, 0, "If-Modified-Since ");
            list_store.append (out iter);
            list_store.set (iter, 0, "If-None-Match");
            list_store.append (out iter);
            list_store.set (iter, 0, "If-Range");
            list_store.append (out iter);
            list_store.set (iter, 0, "If-Unmodified-Since");
            list_store.append (out iter);
            list_store.set (iter, 0, "Max-Forwards");
            list_store.append (out iter);
            list_store.set (iter, 0, "Pragma");
            list_store.append (out iter);
            list_store.set (iter, 0, "Proxy-Authorization");
            list_store.append (out iter);
            list_store.set (iter, 0, "Range");
            list_store.append (out iter);
            list_store.set (iter, 0, "Referer");
            list_store.append (out iter);
            list_store.set (iter, 0, "TE");
            list_store.append (out iter);
            list_store.set (iter, 0, "Transfer-Encoding");
            list_store.append (out iter);
            list_store.set (iter, 0, "Upgrade");
            list_store.append (out iter);
            list_store.set (iter, 0, "User-Agent");
            list_store.append (out iter);
            list_store.set (iter, 0, "Via");
            list_store.append (out iter);
            list_store.set (iter, 0, "Warning");
            
            
            return completion;
        }
    }
}
