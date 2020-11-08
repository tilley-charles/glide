# glide - Utility to transfer code from a text editor to a statistical software GUI

## Use
  - The executable will transfer code from a text editor to a statistical software GUI (e.g., Stata, RStudio, etc.).
  - A _single_ keystroke can be used to transfer code to _different_ statistical software GUIs.
    - This process is dictated by the program's file extension.
    - Each section of the INI file pertains to a different native software GUI. Make any modifications in the appropriate section.
  - If the statistical software (native) GUI is not already open, a new instance will be created.
    - Otherwise, the most recently active window of the native software will be used to execute commands.
    - If the native software GUI is Stata, all Data Editor/Browser and Viewer windows will be closed to reduce clutter.
  - The executable is designed to transfer text to a GUI (as opposed to submitting batch jobs).

## Setup
  - Update the values in the INI file to match the setup on your machine.
    - [path]     - file path to native software GUI
    - [wintitle] - PERL/PHP regular expression describing window title of native software
    - [wait]     - wait time after launching native software executable
    - [command]  - set of keystrokes to be sent to the native software
    - [text]     - text to be sent to the native software GUI (i.e., what would be typed in GUI command prompt)

  - Map keys in your text editor of choice to command line calls.
    - You may map a different keystroke to the **text** and **script** behavior.
    - [text]     - run selected text (or current line if no text is selected)
    - [script]   - run entire script

## Integration
  - Invoke with a command line call:
    - [argument 1] - executable
    - [argument 2] - file extension of script (or full file path and file name with extension)
    - [argument 3] - behavior (run selected text or entire script)

  - Example calls (should be mapped to keystrokes):
    - "glide.exe" "C:/..../myscript.do" "text"
    - "glide.exe"         "myscript.do" "script"
    - "glide.exe"                 ".do" "text"
    - "glide.exe"                  "do" "script"

## Acknowledgements
This routine builds off other excellent approaches to integrate text editors and statistical software GUIs.
  - Friedrich Huebler
    - https://huebler.blogspot.com/2008/04/stata.html
  - Keith Kranker
    - https://bitbucket.org/keithk/notepad-stats-integration/wiki/Home
  - Jelmer Ypma
    - https://www.ucl.ac.uk/~uctpjyy/downloads.html

