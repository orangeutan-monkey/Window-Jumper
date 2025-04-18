using System; 
using System.Diagnostics;
using System.Runtime.InteropServices; 
using System.Windows.Input; 

namespace Window_Jumper
{
    public class GlobalKeyboardHook
    {
        private const int WH_KEYBOARD_LL = 13; 
        private const int WM_KEYDOWN = 0x0100; 
        private const int WM_KEYUP = 0x0101; 
        private const int WM_SYSKEYDOWN = 0x0104; 
        private const int WM_SYSKEYUP = 0x0105; 
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn,IntPtr hMod. uint dwThreadId);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool UnhookedWindowsHookEx(IntPtr hhk);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam,IntPtr lParam);
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr GetModuleHandle(string lpModuleName);
        public delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);
        public event EventHandler<KeyEventArgs> KeyDown; 
        public event EventHandler<KeyEventArgs> KeyUp;
        private LowLevelKeyboardProc _proc;
        private IntPtr _hookID = IntPtr.zero; 
        public GlobalKeyboardHook()
        {
            _proc = HookCallback;
        } 
        public void Hook()
        {
            IntPtr hInstance = GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName);
            _hookID = SetWindowsHookEx(WH_KEYBOARD_LL,_proc,hInstance, 0);
        }
        public void Unhook()
        {
            UnhookedWindowsHookEx(_hookID);
        }
        private IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
        {
            if(nCode >= 0)
            {
                int vkCode = Marshal.ReadInt32(lParam);
                Key key = KeyInterop.KeyFromVirtualKey(vkCode);
                if(wParam == (IntPtr)WM_KEYDOWN || wParam == (IntPtr)WM_SYSKEYDOWN)
                {
                    KeyDown?.Invoke(this, new KeyEventArgs(key));
                }

            }
            return CallNextHookEx(_hookID,nCode,wParam,lParam);
        }

    }
}