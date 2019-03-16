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

namespace Spectator.Plugins.Utils {
    public string read_file (string path) {
        var file = File.new_for_path (path);
        var builder = new StringBuilder ();

        try {
            // Open file for reading and wrap returned FileInputStream into a
            // DataInputStream, so we can read line by line
            var dis = new DataInputStream (file.read ());
            string line;
            // Read lines until end of file (null) is reached
            while ((line = dis.read_line (null)) != null) {
                builder.append (line);
                builder.append ("\n");
            }
        } catch (Error e) {
            error ("%s", e.message);
        }

        return builder.str;
    }

//#define   SOUP_URI_VALID_FOR_HTTP(uri) ((uri) && ((uri)->scheme == SOUP_URI_SCHEME_HTTP || (uri)->scheme == SOUP_URI_SCHEME_HTTPS) && (uri)->host && (uri)->path)

    public bool valid_uri (Soup.URI uri) {
        return uri != null &&
               (uri.get_scheme () == "http" || uri.get_scheme () == "https") &&
               uri.get_host ().length > 0 &&
               uri.get_path ().length >= 0;
    }

    public void set_information (Plugin plugin, string json_path) {
        string json = read_file (json_path);

        if (json != "") {
            var parser = new Json.Parser ();
            try {
                parser.load_from_data (json);
                // TODO:  Error if root is no object
                var root = parser.get_root ();
                var object = root.get_object ();

                // TODO: Error handling
                plugin.author = object.get_string_member ("author");
                plugin.name = object.get_string_member ("name");
                plugin.description = object.get_string_member ("description");
                plugin.version = object.get_string_member ("version");
            } catch (Error e) {
                // Do something funny
            }
        }
    }
}
