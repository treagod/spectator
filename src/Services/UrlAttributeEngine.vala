/*
* Copyright (c) 2020 Marvin Ahlgrimm (https://github.com/treagod)
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

namespace Spectator.Services {
    public class UrlVariableEngine {
        private struct HighlightPosition {
            uint start;
            uint end;
            bool valid;

            public HighlightPosition (uint start, uint end, bool valid) {
                this.start = start;
                this.end = end;
                this.valid = valid;
            }
        }

        private weak Gtk.Entry url_entry;

        public UrlVariableEngine (Gtk.Entry url_entry) {
            this.url_entry = url_entry;
            this.url_entry.changed.connect (() => {
                update_highlighting ();
            });
            this.url_entry.delete_text.connect (handle_variable_deletion);
        }

        private void handle_variable_deletion (int start_pos, int end_pos) {
            var deleted_text = this.url_entry.text.substring(start_pos, end_pos - start_pos);

            // If only a } is deleted, delete everything until and including #{
            if (deleted_text.length == 1) {
                if (deleted_text == "}") {
                    handle_single_curly_brace (start_pos);
                } else if (deleted_text == "#") {
                    handle_single_hashtag_brace (start_pos);
                }
            } else if (deleted_text.contains ("}")) {
            }
        }

        private void handle_single_curly_brace (int start_pos) {
            var pos = find_start_pos_of_variable (start_pos);

            if (pos != -1) {
                this.url_entry.delete_text (pos, start_pos + 1);
            }
        }

        private int find_start_pos_of_variable (int end_pos) {
            for(int i = end_pos; i >= 0; i--) {
                if (this.url_entry.text.get_char(i) == '{') {
                    i--;

                    if (i >= 0 && this.url_entry.text.get_char(i) == '#') {
                        return i;
                    }
                }
            }
            return -1;
        }

        private void handle_single_hashtag_brace (int start_pos) {
            var next_char = this.url_entry.text.get_char (start_pos + 1).to_string ();
            if (next_char == "{") {
                var pos = this.url_entry.text.index_of_char ('}', start_pos);

                if (pos != -1) {
                    this.url_entry.delete_text (start_pos, pos + 1);
                }
            }
        }

        public void update_highlighting () {
            unowned string url = url_entry.text;
            unichar c;
            url_entry.attributes = new Pango.AttrList ();

            for (int i = 0; url.get_next_char (ref i, out c);) {
                var position = calculate_next_variable_position (url, ref i , ref c);

                if (position.valid) {
                    highlight_variable (position);
                }
            }
        }

        private HighlightPosition calculate_next_variable_position (string url, ref int i, ref unichar c) {
            var found_variable = false;
            uint start = 0;
            uint end = 0;

            if (c == '#') {
                start = i;
                url.get_next_char (ref i, out c);

                if (c == '{') {
                    var s = "";
                    while (true) {
                        url.get_next_char (ref i, out c);
                        if (c == '}') {
                            found_variable = true;
                            break;
                        }

                        if (c == '\0') {
                            break;
                        }
                        s += c.to_string ();
                    }
                    end = i;
                }
            }

            return HighlightPosition(start, end, found_variable);
        }

        private void highlight_variable (HighlightPosition position) {
            colorize_variable (position);
            emphasize_variable (position);
            hide_variable_indicator (position);
        }

        private void emphasize_variable (HighlightPosition position) {
            var font_weight = Pango.attr_weight_new (Pango.Weight.BOLD);
            font_weight.start_index = position.start - 1;
            font_weight.end_index = position.end;
            url_entry.attributes.insert ((owned) font_weight);
        }

        private void colorize_variable (HighlightPosition position) {
            var font_color = (Pango.AttrColor) Pango.attr_foreground_new (0,0,0);
            font_color.color.parse ("#0e9a83");
            font_color.start_index = position.start - 1;
            font_color.end_index = position.end;
            url_entry.attributes.insert ((owned) font_color);
        }

        private void hide_variable_indicator (HighlightPosition position) {
            var font_scale = Pango.attr_scale_new (0);
            font_scale.start_index = position.start - 1;
            font_scale.end_index = position.start + 1;
            url_entry.attributes.insert ((owned) font_scale);

            font_scale = Pango.attr_scale_new (0);
            font_scale.start_index = position.end - 1;
            font_scale.end_index = position.end;
            url_entry.attributes.insert ((owned) font_scale);
        }
    }
}
