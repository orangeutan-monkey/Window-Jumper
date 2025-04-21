using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Diagnostics.CodeAnalysis;
using System.Diagnostics.Eventing.Reader;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;

namespace Window_Jumper
{
        public partial class App : Application
    {
        private Mutex _mutex; 
        private const string MutexName = "WindowJumperSingleInstanceMutex";
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            bool createdNew; 
            _mutex = new Mutex(true, MutexName, out createdNew);
            if(!createdNew)
            {
                MessageBox.Show("Another instance of Window Jumper is running in the background. \nUse the hotkey to show/hide the browser or check the system tray. ", 
                "Window Jumper", MessageBoxButton.OK, MessageBoxImage.Information);
                Shutdown();
                return;
            }
            AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandedException;
            Current.DispatcherUnhandledException +=  Current_DispatcherUnhandedException;
            string appDataPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),"Window Jumper");
            if(!Directory.Exists(appDataPath))
            {
                Directory.CreateDirectory(appDataPath);
            }

        }
        private void CurrentDomain_UnhandedException(object sender, UnhandledExceptionEventArgs e)
        {
            Exception exception = e.ExceptionObject as Exception;
            LogException(exception);
            if(e.IsTerminating)
            {
                MessageBox.Show($"An unhandled exception has occured: {exception?.Message}\nThe application will now close.","Error",MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        private void Current_DispatcherUnhandedException(object sender, System.Windows.Threading.DispatcherUnhandledExceptionEventArgs e)
        {
            LogException(e.Exception);
            MessageBox.Show($"An unhandled exception has occured: {e.Exception.Message}", "Error",MessageBoxButton.OK, MessageBoxImage.Error);
            e.Handled = true; 
        }
        private void LogException(Exception e)
        {
            if(e == null)
            {
                return;
            }
            try
            {
                string logPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),"Window Jumper","error.log");
                string logMessage = $"[{DateTime.Now}] Exception: {e.Message}\nStackTrace: {e.StackTrace}\n\n";
                File.AppendAllText(logPath, logMessage);
            }
            catch
            {
    
            }
        }
        protected override void OnExit(ExitEventArgs e)
        {
            _mutex?.ReleaseMutex();
            _mutex?.Dispose();
            base.OnExit(e);
        }
    }
}
