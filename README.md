# Window Jumper

A lightweight background web browser for Windows that can be toggled with customizable keyboard shortcuts. This application runs in the background and can be quickly shown or hidden with a global keyboard shortcut.

## Features

- Runs as a background process with minimal UI
- Disguises itself as a system process for improved resilience
- Toggles visibility with customizable keyboard shortcuts (default: Ctrl+Alt+J)
- Includes system tray integration for easy access
- Persists user settings between sessions
- Easy to install with a Windows MSI installer

## Requirements

- Windows 10 or later
- .NET Framework 4.7.2
- Microsoft Edge WebView2 Runtime (automatically installed with the installer)

## Getting Started

### Installation

1. Download the latest MSI installer from the Releases page
2. Run the installer and follow the prompts
3. Window Jumper will start automatically after installation

### Using Window Jumper

- Press the configured keyboard shortcut (default: Ctrl+Alt+J) to show or hide the browser
- Use the system tray icon to access additional options:
  - Toggle Window: Show or hide the browser
  - Settings: Configure browser options
  - Exit: Completely close the application

### Configuration

Access the settings dialog through:
- The system tray icon's context menu
- The gear icon in the browser's address bar
- Right-clicking in the browser and selecting "Window Jumper Settings"

Settings include:
- Homepage URL
- Window size
- Toggle keyboard shortcut
- Startup behavior
- Always-on-top option

## Building from Source

### Prerequisites

- [.NET Framework 4.7.2](https://dotnet.microsoft.com/download/dotnet-framework/net472)
- [Visual Studio 2019](https://visualstudio.microsoft.com/) or newer
- [WiX Toolset v3.11](https://wixtoolset.org/releases/) (for building the installer)

### Build Instructions

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/WindowJumper.git
   cd WindowJumper
   ```

2. Build the project in Visual Studio:
   - Open the solution in Visual Studio
   - Build the solution (Build > Build Solution)

3. Create the installer:
   ```
   powershell -File build.ps1 -Release -Installer
   ```

4. Find the built installer at `bin\Release\WindowJumper.msi`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This application is for educational purposes only.

Developed and Copyrighted by Anirudh Deveram 
