using System;
using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Window_Jumper
{
    public class AppSettings
    {
        private static readonly string settingsFilePath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
            "Window Jumper",
            "settings.json"
        );
        
        [JsonPropertyName("homepage")]
        public string Homepage { get; set; } = "https://www.google.com";
        
        [JsonPropertyName("autoStart")]
        public bool AutoStart { get; set; } = true;
        
        [JsonPropertyName("alwaysOnTop")]
        public bool AlwaysOnTop { get; set; } = true;
        
        [JsonPropertyName("hideOnStart")]
        public bool HideOnStart { get; set; } = true;
        
        [JsonPropertyName("hideModKeys")]
        public int HideModKeys { get; set; } = 6; // MOD_Control | MOD_Alt = 6
        
        [JsonPropertyName("hideKey")]
        public uint HideKey { get; set; } = 0x4A; // J key
        
        [JsonPropertyName("windowWidth")]
        public double WindowWidth { get; set; } = 800;
        
        [JsonPropertyName("windowHeight")]
        public double WindowHeight { get; set; } = 800;
        
        public static AppSettings Load()
        {
            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(settingsFilePath));
                if (File.Exists(settingsFilePath))
                {
                    string json = File.ReadAllText(settingsFilePath);
                    return JsonSerializer.Deserialize<AppSettings>(json) ?? new AppSettings();
                }
            }
            catch (Exception e)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading settings: {e.Message}");
            }
            return new AppSettings();
        }
        
        public void Save()
        {
            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(settingsFilePath));
                string json = JsonSerializer.Serialize(this, new JsonSerializerOptions { WriteIndented = true });
                File.WriteAllText(settingsFilePath, json);
            }
            catch (Exception e)
            {
                System.Diagnostics.Debug.WriteLine($"Error saving settings: {e.Message}");
            }
        }
    }
}