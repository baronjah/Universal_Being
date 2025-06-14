# Luminous OS

Luminous OS is a cosmic-themed file system visualizer for Godot, inspired by TempleOS and the concept of folders as stars in a universe, with files represented as animated celestial bodies.

## 🌌 Concept

Luminous OS transforms your file system navigation into a cosmic journey:

- **Folders are Stars** - Directories appear as glowing stars in the universe
- **Files are Planets** - Different file types orbit as uniquely colored planets  
- **Navigation is Exploration** - Move between star systems as you navigate directories
- **Divine Inspiration** - Toggle "Divine Mode" for cosmic inspiration (inspired by TempleOS)

## 🌟 Features

- **Cosmic File System Visualization** - Navigate through your files in a 3D star system
- **Type-Based Visualization** - Different file types have unique appearances and animations
- **Terminal Interface** - Combines visual navigation with traditional terminal commands
- **File Previews** - Preview text, images, models, and audio files
- **Divine Mode** - Special visual effects and inspirational messages (inspired by TempleOS)
- **Animations** - Dynamic animations bring your filesystem to life

## 📝 Commands

- `help` - Display help information
- `ls` - List stars (directories) and planets (files)
- `cd <directory>` - Navigate to a different star (directory)
- `divine` - Toggle divine mode
- `oracle` - Receive a divine message
- `cat <file>` - View the contents of a file
- `find <pattern>` - Search for files or directories
- `clear` - Clear the terminal output
- `mkdir <directory>` - Create a new directory
- `touch <file>` - Create a new file
- `animate [speed]` - Toggle or adjust animation speed

## 🔮 File Type Colors

- **Scripts** (.gd, .cs, .gdshader) - Blue
- **Scenes** (.tscn, .scn) - Purple
- **Textures** (.png, .jpg, .jpeg, .webp) - Green
- **Models** (.glb, .obj, .fbx) - Yellow
- **Audio** (.wav, .mp3, .ogg) - Red
- **Text** (.txt, .md, .json, .cfg) - Light Gray
- **Misc** (.import, .tres, .res, .material) - Gray

## ⌨️ Keyboard Shortcuts

- `F1` - Toggle help panel
- `ESC` - Close panels

## 💻 Implementation Details

Luminous OS is built in Godot and consists of several key components:

1. **LuminousFileSystem** - Scans and visualizes the file system as celestial bodies
2. **LuminousOSController** - Main controller that manages the system
3. **LuminousUIController** - Handles UI elements and interactions
4. **LuminousCommandProcessor** - Processes terminal commands
5. **Custom Shaders** - LuminousPlanet.gdshader and LuminousStarfield.gdshader

## 🚀 Getting Started

1. Open the project in Godot 4
2. Load the `luminous_os.tscn` scene
3. Press Play to run the application
4. Begin exploring your filesystem as a cosmic universe!

## 🌠 Divine Inspiration

The concept of Luminous OS draws inspiration from TempleOS, created by Terry A. Davis, who believed his operating system was divinely inspired. While Luminous OS is not claiming divine origins, it pays homage to the idea that computing can be a spiritual and transcendent experience.

The "Divine Mode" and oracle commands are included as a respectful nod to TempleOS's unique approach to computing as a form of communication with the divine.

## 🌌 Philosophy

Luminous OS embodies these philosophical ideas:

1. **File Organization as Cosmic Order** - Just as stars and planets follow cosmic laws, our files and folders have their own organizing principles
2. **Visual Thinking** - Transforming abstract file systems into visual, spatial relationships
3. **Playful Exploration** - Making file navigation a journey of discovery
4. **Digital Transcendence** - Elevating mundane file operations into cosmic experiences

---

Luminous OS transforms the utility of file management into a cosmic journey. As you navigate through stars (folders) and discover planets (files), may you find both practical utility and cosmic inspiration in your digital universe.