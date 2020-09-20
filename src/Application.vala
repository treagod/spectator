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

namespace Spectator {

    public class Order {
        public enum Type {
            REQUEST,
            COLLECTION
        }

        public Type type;
        public uint id;

        public Order (uint id, Type type) {
            this.type = type;
            this.id = id;
        }
    }

    public interface ICollectionService : Object {
        public abstract Gee.ArrayList<Models.Collection> get_collections ();
        public abstract bool add_collection (Models.Collection collection);
        public abstract bool delete_collection (uint id);
        public abstract bool add_request_to_collection (uint collection, uint request_id);
        public abstract bool add_request_to_collection_begin (uint collection, uint request_id);
        public abstract Models.Collection? get_collection_by_id (uint id);
        public abstract void append_after_request_to_collection (uint collection_id, uint target_id, uint moved_id);
    }

    public class TestCollectionService : ICollectionService, Object {
        private Gee.ArrayList<Models.Collection> collections;
        private Repository.IRequest request_service;

        public signal void collection_added (Models.Collection collection);
        public signal void collection_deleted (uint id);

        public TestCollectionService (Repository.IRequest request_service) {
            this.collections = new Gee.ArrayList<Models.Collection> ();
            this.request_service = request_service;
        }
        public Gee.ArrayList<Models.Collection> get_collections () {
            return this.collections;
        }

        public bool delete_collection (uint id) {
            foreach (var collection in this.collections) {
                if (collection.id == id) {
                    foreach (var req_id in collection.request_ids) {
                        this.request_service.delete_request (req_id);
                    }
                    this.collections.remove (collection);

                    this.collection_deleted (id);
                    break;
                }
            }
            return true;
        }

        public bool add_request_to_collection_begin (uint collection_id, uint request_id) {
            var collection = this.get_collection_by_id (collection_id);

            if (collection != null) {
                collection.request_ids.insert (0, request_id);
                this.request_service.set_collection_id_for_request (request_id, collection_id);
            } else {
                return false;
            }

            return true;
        }

        public bool add_request_to_collection (uint collection_id, uint request_id) {
            var collection = this.get_collection_by_id (collection_id);

            if (collection != null) {
                collection.add_request_id (request_id);
                this.request_service.set_collection_id_for_request (request_id, collection_id);
            } else {
                return false;
            }

            return true;
        }

        public bool add_collection (Models.Collection collection) {
            this.collections.add (collection);
            this.collection_added (collection);
            return true;
        }

        public Models.Collection? get_collection_by_id (uint id) {
            Models.Collection collection = null;

            foreach (var col in this.collections) {
                if (col.id == id) {
                    collection = col;
                    break;
                }
            }

            return collection;
        }

        public void append_after_request_to_collection (uint collection_id, uint target_id, uint moved_id) {
            var idx = 0;
            var collection = this.get_collection_by_id (collection_id);

            collection.request_ids.remove (moved_id);

            // Get position to insert after
            for (var i = 0; i < collection.request_ids.size; i++) {
                if (collection.request_ids[i] == target_id) {
                    idx = i;
                    break;
                }
            }
            collection.request_ids.insert (idx + 1, moved_id);
        }
    }

    public class Application : Gtk.Application {
        // Avoid multiple instances
        public bool running = false;
        private string app_data_dir = Path.build_filename (
            Environment.get_home_dir (),
            ".local",
            "share",
            Constants.PROJECT_NAME,
            "%s.db".printf (Constants.PROJECT_NAME)
        );
        private Sqlite.Database db;
        construct {
            flags |= ApplicationFlags.HANDLES_OPEN;
            application_id = "com.github.treagod.spectator";
        }

        private void load_database () {
            string errmsg;

            int ec = Sqlite.Database.open (this.app_data_dir, out db);
            if (ec != Sqlite.OK) {
                stderr.printf ("Can't open database: %d: %s\n", db.errcode (), db.errmsg ());
                //  return -1;
            }

            string query = Spectator.SQL_INIT_CMD;

            ec = db.exec (query, null, out errmsg);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %s\n", errmsg);
                //  return -1;
            }
        }

        protected override void activate () {
            this.load_database ();
            if (!running) {
                var rs = new Repository.SQLiteRequest (db);
                var cs = new TestCollectionService (rs);
                var os = new Repository.SQLiteCustomOrder (db);

                var window = new Spectator.Window(this, rs, cs, os);
                this.add_window (window);

                window.show_all ();
                running = true;
            }
        }
    }
}
