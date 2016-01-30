namespace ETerm {

    public const string[] ACCEL_COPY =       { "<Primary><Shift>c" };
    public const string[] ACCEL_PASTE =      { "<Primary><Shift>v" };
    public const string[] ACCEL_NEW_WINDOW = { "<Primary><Shift>n" };
    public const string[] ACCEL_NEW_TAB =    { "<Primary><Shift>t" };
    public const string[] ACCEL_CLOSE_TAB =  { "<Primary><Shift>w" };

    public enum WindowState {
        TERMINAL,
        GRID,
        NO_STARTED,
    }
}
