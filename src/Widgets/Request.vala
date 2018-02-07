namespace HTTPInspector {
    class Request : Gtk.Box {
        public Request () {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 4;

            var url_entry = new UrlEntry ();
            url_entry.margin_bottom = 10;

            var stack = new Gtk.Stack ();
            stack.margin = 6;
            stack.margin_bottom = 18;
            stack.margin_top = 18;
            var stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.set_stack (stack);
            stack_switcher.halign = Gtk.Align.CENTER;

            stack.add_titled (new HeaderTab (),"Header", "Header");
            stack.add_titled (new Gtk.Label ("12435243"),"URL Params", "URL Params");
            stack.add_titled (new Gtk.Label ("12435243"),"Body", "Body");
            //stack.add_titled (new Gtk.Label ("12435243"),"Auth", "Auth");
            //stack.add_titled (new Gtk.Label ("12435243"),"Options", "Options");


            add (url_entry);
            add (stack_switcher);
            add (stack);
        }
    }
}
