namespace HTTPInspector {
    class HeaderBar : Gtk.HeaderBar {
        private Gtk.Button _new_request;
        
        public Gtk.Button new_request {
            get { return _new_request; }
        }
        
        public HeaderBar () {
            Object (
                has_subtitle: true,
                show_close_button: true
            );
        }
        
        construct {
            _new_request = new Gtk.Button.from_icon_name ("bookmark-new", Gtk.IconSize.LARGE_TOOLBAR);
            _new_request.tooltip_text = _("Create Request");
            
            var preferences_menuitem = new Gtk.ModelButton ();
            preferences_menuitem.text = _("Preferences");
            
            var about_menuitem = new Gtk.ModelButton ();
            about_menuitem.text = _("About");
            
            var menu_grid = new Gtk.Grid ();
            menu_grid.margin = 7;
            menu_grid.orientation = Gtk.Orientation.VERTICAL;
            menu_grid.add (about_menuitem);
            menu_grid.add (preferences_menuitem);
            
            menu_grid.show_all ();
            
            var menu = new Gtk.Popover (null);
            menu.add (menu_grid);
            
            var app_menu = new Gtk.MenuButton ();
            app_menu.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
            app_menu.tooltip_text = _("Menu");
            app_menu.popover = menu;
            
            title = "HTTP Inspector";
            subtitle = "";
            pack_start (_new_request);
            pack_end (app_menu);
        }
    }
}
