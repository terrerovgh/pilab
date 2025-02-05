from flask import Flask, render_template, request, jsonify, Response
import subprocess
import os
import re
from functools import wraps

app = Flask(__name__)

def security_headers(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        resp = f(*args, **kwargs)
        headers = {
            'X-Content-Type-Options': 'nosniff',
            'X-Frame-Options': 'DENY',
            'X-XSS-Protection': '1; mode=block',
            'Content-Security-Policy': "default-src 'self';"
        }
        if isinstance(resp, Response):
            for key, value in headers.items():
                resp.headers[key] = value
        return resp
    return decorated_function

@app.route('/')
@security_headers
def index():
    return render_template('index.html')

@app.route('/configure-wifi', methods=['POST'])
@security_headers
def configure_wifi():
    try:
        ssid = request.form.get('ssid', '')
        password = request.form.get('password', '')
        
        # Validate inputs
        if not ssid or not password:
            return jsonify({'status': 'error', 'message': 'SSID and password are required'}), 400
            
        if not re.match(r'^[A-Za-z0-9_-]{1,32}$', ssid):
            return jsonify({'status': 'error', 'message': 'Invalid SSID format'}), 400
            
        if len(password) < 8 or len(password) > 63:
            return jsonify({'status': 'error', 'message': 'Password must be between 8 and 63 characters'}), 400
        
        # Create wpa_supplicant entry with sanitized inputs
        wpa_config = f'''
network={{
    ssid="{ssid.replace('"', '\\"')}"
    psk="{password.replace('"', '\\"')}"
    key_mgmt=WPA-PSK
    scan_ssid=1
}}
'''
        
        with open('/etc/wpa_supplicant/wpa_supplicant.conf', 'a') as f:
            f.write(wpa_config)
        
        # Reconfigure wireless interface
        subprocess.run(['wpa_cli', '-i', 'wlan0', 'reconfigure'], check=True)
        
        return jsonify({'status': 'success', 'message': 'WiFi configuration saved successfully'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=False)