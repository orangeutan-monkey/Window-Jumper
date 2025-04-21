using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using Microsoft.Win32;
using System.Diagnostics;

namespace Window_Jumper
{
    public partial class SettingsDialog : Window
    {
        private AppSettings _settings;
        private bool _isRecordingHotkey = false;
        
        public SettingsDialog(AppSettings settings)
        {
            InitializeComponent();
            _settings = settings;
            txtHomepage.Text = _settings.Homepage;
            chkAutoStart.IsChecked = _settings.AutoStart;
            chkAlwaysOnTop.IsChecked = _settings.AlwaysOnTop;
            chkHideOnStart.IsChecked = _settings.HideOnStart;
            txtWidth.Text = _settings.WindowWidth.ToString();
            txtHeight.Text = _settings.WindowHeight.ToString();
            UpdateHotkeyDisplay();
            PreviewKeyDown += SettingsDialog_PreviewKeyDown;
        }        private void UpdateHotkeyDisplay()
        {
            string modifiers = "";
            if((_settings.HideModKeys & 1) != 0)
            {
                modifiers += "Alt+";
            }
            if((_settings.HideModKeys & 2) != 0)
            {
                modifiers += "Ctrl+";
            }
            if((_settings.HideModKeys & 4) != 0)  // Fixed from 3 to 4 for MOD_SHIFT
            {
                modifiers += "Shift+";
            }
            Key key = KeyInterop.KeyFromVirtualKey((int)_settings.HideKey);
            string keyName = key.ToString(); 
            txtHotkey.Text = modifiers + keyName;  // Fixed variable name from txtHotKey to txtHotkey
        }
        
        private void BtnChangeHotkey_Click(object sender, RoutedEventArgs e)  // Fixed method name
        {
            if(_isRecordingHotkey)
            {
                _isRecordingHotkey = false; 
                btnChangeHotkey.Content = "Change";  // Fixed variable name
                txtHotkey.Background = System.Windows.Media.Brushes.WhiteSmoke;  // Fixed variable name
            }
            else
            {
                _isRecordingHotkey = true;
                btnChangeHotkey.Content = "Press Keys";  // Fixed variable name
                txtHotkey.Text = "Press new hotkey combination...";  // Fixed variable name
                txtHotkey.Background = System.Windows.Media.Brushes.LightYellow;  // Fixed namespace and variable name
                txtHotkey.Focus();  // Fixed variable name
            }
        }
         
        private void SettingsDialog_PreviewKeyDown(object sender, KeyEventArgs e)
        {
            if (_isRecordingHotkey)
            {
                e.Handled = true;
                
                Key key = e.Key == Key.System ? e.SystemKey : e.Key;
                if (key == Key.LeftAlt || key == Key.RightAlt ||
                    key == Key.LeftCtrl || key == Key.RightCtrl ||
                    key == Key.LeftShift || key == Key.RightShift)
                {
                    return;
                }
       
                int modifierKeys = 0;
                if (Keyboard.IsKeyDown(Key.LeftAlt) || Keyboard.IsKeyDown(Key.RightAlt))
                    modifierKeys |= 1; // MOD_ALT
                if (Keyboard.IsKeyDown(Key.LeftCtrl) || Keyboard.IsKeyDown(Key.RightCtrl))
                    modifierKeys |= 2; // MOD_CONTROL
                if (Keyboard.IsKeyDown(Key.LeftShift) || Keyboard.IsKeyDown(Key.RightShift))
                    modifierKeys |= 4; // MOD_SHIFT
         
                if (modifierKeys == 0)
                {
                    MessageBox.Show("Please include at least one modifier key (Ctrl, Alt, or Shift) with your hotkey.",
                        "Hotkey Recording", MessageBoxButton.OK, MessageBoxImage.Information);
                    return;
                }
                
                uint keyCode = (uint)KeyInterop.VirtualKeyFromKey(key);

                _settings.HideModKeys = modifierKeys;  // Changed to match property name in AppSettings
                _settings.HideKey = keyCode;

                UpdateHotkeyDisplay();

                _isRecordingHotkey = false;
                btnChangeHotkey.Content = "Change";
                txtHotkey.Background = System.Windows.Media.Brushes.WhiteSmoke;
            }
        }
        
        private void BtnSave_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                _settings.Homepage = txtHomepage.Text;
                _settings.AutoStart = chkAutoStart.IsChecked ?? false;
                _settings.AlwaysOnTop = chkAlwaysOnTop.IsChecked ?? true;
                _settings.HideOnStart = chkHideOnStart.IsChecked ?? true;
                
                if (double.TryParse(txtWidth.Text, out double width) && width >= 200)
                    _settings.WindowWidth = width;
                else
                {
                    MessageBox.Show("Window width must be a valid number greater than or equal to 200.",
                        "Invalid Value", MessageBoxButton.OK, MessageBoxImage.Warning);
                    txtWidth.Focus();
                    return;
                }
                
                if (double.TryParse(txtHeight.Text, out double height) && height >= 200)
                    _settings.WindowHeight = height;
                else
                {
                    MessageBox.Show("Window height must be a valid number greater than or equal to 200.",
                        "Invalid Value", MessageBoxButton.OK, MessageBoxImage.Warning);
                    txtHeight.Focus();
                    return;
                }
                _settings.Save();
                DialogResult = true;
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error saving settings: {ex.Message}", "Error", 
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        
        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;
            Close();
        }
    }
}