#!/usr/bin/env python3
import subprocess

def get_ai_status():
    try:
        # Check if Ollama is running
        result = subprocess.run(['systemctl', 'is-active', 'ollama'],
                              capture_output=True, text=True, timeout=1)
        if result.returncode == 0 and 'active' in result.stdout:
            # Get current model
            model_result = subprocess.run(['ollama', 'ps'],
                                         capture_output=True, text=True, timeout=1)
            if model_result.returncode == 0 and model_result.stdout:
                lines = model_result.stdout.strip().split('\n')
                if len(lines) > 1:
                    model = lines[1].split()[0] if lines[1] else 'Unknown'
                    return f"ONLINE: {model}", "#c54dff"
            return "ONLINE", "#c54dff"
    except:
        pass
    return "OFFLINE", "#ff0055"

if __name__ == "__main__":
    text, color = get_ai_status()
    # Output format for Waybar: text|color|tooltip
    print(f"{text}|{color}|AI Engine Status: {text}")
