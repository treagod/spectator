
namespace Spectator {
    [Compact]
    public class Woop {
        public int i;

        public Woop () {
            this.i = 1;
        }
    }

    public void whatever () {
        var s = new Gee.ArrayList<Woop> ();

        s.add (new Woop ());
    }
}
