import os
import json
import subprocess
import time
from pathlib import Path

def get_firefox_profile_path():
    """Get the default Firefox profile directory on macOS."""
    base = os.path.expanduser('~/Library/Application Support/Firefox/Profiles')
    
    profiles_ini = os.path.join(os.path.dirname(base), 'profiles.ini')
    if not os.path.exists(profiles_ini):
        raise FileNotFoundError("Firefox profiles.ini not found")
    
    # Read profiles.ini to find default profile
    with open(profiles_ini, 'r') as f:
        for line in f:
            if 'Default=' in line and line.strip().endswith('1'):
                # Get the next line containing Path=
                profile_path = next(f).strip().split('=')[1]
                return os.path.join(base, profile_path)
    
    raise FileNotFoundError("Default Firefox profile not found")

def get_display_info():
    """Get detailed display information from macOS."""
    try:
        cmd = ['system_profiler', 'SPDisplaysDataType', '-json']
        output = subprocess.check_output(cmd).decode()
        data = json.loads(output)
        
        # Get the displays list
        displays = data.get('SPDisplaysDataType', [{}])[0].get('spdisplays_ndrvs', [])
        
        # Count external displays by filtering out the built-in display
        external_displays = [
            d for d in displays 
            if isinstance(d, dict) and 
            d.get('spdisplays_connection_type') != 'spdisplays_internal'
        ]
        
        # Get the main display name
        main_display = next(
            (d.get('_name') for d in displays if d.get('spdisplays_main') == 'spdisplays_yes'),
            None
        )
        
        return {
            'total_displays': len(displays),
            'external_displays': len(external_displays),
            'main_display': main_display,
            'has_external': len(external_displays) > 0
        }
    except Exception as e:
        print(f"Error getting display info: {e}")
        return {
            'total_displays': 1,
            'external_displays': 0,
            'main_display': 'Color LCD',
            'has_external': False
        }

def update_firefox_zoom(zoom_level):
    """Update Firefox zoom level in user.js."""
    profile_path = get_firefox_profile_path()
    user_js_path = os.path.join(profile_path, 'user.js')
    
    # Read existing user.js if it exists
    existing_prefs = {}
    if os.path.exists(user_js_path):
        with open(user_js_path, 'r') as f:
            for line in f:
                if line.startswith('user_pref('):
                    # Parse the preference line
                    pref = line.strip().split('user_pref(')[1].split(');')[0]
                    key, value = pref.split(',', 1)
                    existing_prefs[key.strip(' "')] = value.strip()

    # Update zoom preference
    existing_prefs['layout.css.devPixelsPerPx'] = f'"{zoom_level}"'
    
    # Write updated preferences back to user.js
    with open(user_js_path, 'w') as f:
        for key, value in existing_prefs.items():
            f.write(f'user_pref("{key}", {value});\n')

def main():
    # Configure zoom levels
    LAPTOP_ZOOM = "1.5"  # Adjust this to your preferred laptop zoom
    EXTERNAL_ZOOM = "1.2"  # Adjust this to your preferred external monitor zoom
    
    last_display_state = None
    
    print("Monitor detection script running. Press Ctrl+C to stop.")
    print(f"Laptop zoom level: {LAPTOP_ZOOM}")
    print(f"External monitor zoom level: {EXTERNAL_ZOOM}")
    
    while True:
        display_info = get_display_info()
        display_state = display_info['has_external']
        
        if display_state != last_display_state:
            zoom = EXTERNAL_ZOOM if display_state else LAPTOP_ZOOM
            try:
                update_firefox_zoom(zoom)
                print(f"\nDisplay change detected:")
                print(f"- Total displays: {display_info['total_displays']}")
                print(f"- External displays: {display_info['external_displays']}")
                print(f"- Main display: {display_info['main_display']}")
                print(f"- Updated zoom to: {zoom}")
                last_display_state = display_state
            except Exception as e:
                print(f"Error updating Firefox settings: {e}")
        
        time.sleep(5)  # Check every 5 seconds

if __name__ == "__main__":
    main()
