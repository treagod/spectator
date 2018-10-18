/*
* Copyright (c) 2018 Marvin Ahlgrimm (https://github.com/treagod)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marvin Ahlgrimm <marv.ahlgrimm@gmail.com>
*/

namespace HTTPInspector.Plugins {
    public class Engine : Object {
        public Gee.ArrayList<Plugin> plugins { get; private set; }

        public Engine () {
            load_plugins ();
        }

        private void load_plugins () {
            plugins = new Gee.ArrayList<Plugin> ();
            var plugin_dir = Path.build_filename (Environment.get_home_dir (), ".local", "share",
                                                    Constants.APP_ID, "plugins");

            if (!valid_plugin_dir (plugin_dir)) {
                // throw something
            }

            Dir dir = Dir.open (plugin_dir, 0);

            string? name = null;
            while ((name = dir.read_name ()) != null) {
                var success = load_plugin (plugin_dir, name);

            }
        }

        private bool load_plugin (string dir, string name) {
            string path = Path.build_filename (dir, name);
            if (FileUtils.test (path, FileTest.IS_DIR)) {
                string js_path = Path.build_filename (path, "plugin.js");
                string json_path = Path.build_filename (path, "plugin.json");

                if (plugin_files_exist (js_path, json_path)) {
                    var plugin = new Plugin (Utils.read_file (js_path), json_path);
                    plugins.add (plugin);
                } else {
                    return false;
                }
            }

            return true;
        }

        private bool plugin_files_exist (string js_path, string json_path) {
            return FileUtils.test (js_path, FileTest.EXISTS) &&
                   FileUtils.test (json_path, FileTest.EXISTS);
        }

        private bool valid_plugin_dir (string dir) {
            if (FileUtils.test (dir, FileTest.EXISTS) &&
                !FileUtils.test (dir, FileTest.IS_DIR)) {
                return false;
            } else if (!FileUtils.test (dir, FileTest.EXISTS)) {
                DirUtils.create_with_parents (dir, 0700);
            }


            return FileUtils.test (dir, FileTest.IS_DIR);
        }
    }
}
