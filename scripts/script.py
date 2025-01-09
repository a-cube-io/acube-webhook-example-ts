import sys
import json
import urllib.request
import ssl

def read_env_file(file_path):
    env_vars = {}
    try:
        with open(file_path, 'r') as file:
            for line in file:
                line = line.strip()
                if line and not line.startswith('#'):
                    key, value = line.split('=', 1)
                    env_vars[key.strip()] = value.strip().strip('"\'')
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        sys.exit(1)
    return env_vars

def get_jwt_token(env_vars):
    url = f"{env_vars['COMMON_LOGIN_URL']}/login"
    auth_payload = {
        'email': env_vars['COMMON_LOGIN_EMAIL'],
        'password': env_vars['COMMON_LOGIN_PASSWORD']
    }

    try:
        req = urllib.request.Request(url, method='POST')
        req.add_header('Content-Type', 'application/json')
        req.add_header('Accept', 'application/json')

        context = ssl.create_default_context()
        with urllib.request.urlopen(req, json.dumps(auth_payload).encode(), context=context) as response:
            if response.getcode() == 200:
                data = json.loads(response.read())
                return data.get('token')
            else:
                print(f"Authentication failed. Status code: {response.getcode()}")
                print(response.read())
    except Exception as e:
        print(f"An error occurred during authentication: {str(e)}")
    return None

def get_company_data(company_id, jwt_token):
    url = f"https://api-sandbox.acubeapi.com/verify/company/{company_id}"

    try:
        req = urllib.request.Request(url, method='GET')
        req.add_header('Authorization', f'Bearer {jwt_token}')
        req.add_header('Accept', 'application/json')

        context = ssl.create_default_context()
        with urllib.request.urlopen(req, context=context) as response:
            if response.getcode() == 200:
                return json.loads(response.read())
            else:
                print(f"Company verification failed. Status code: {response.getcode()}")
                print(response.read())
    except Exception as e:
        print(f"An error occurred during company verification: {str(e)}")
    return None

# Main execution
env_vars = read_env_file('.env.local')

if len(sys.argv) != 2:
    print("Usage: python script.py <company_id>")
    sys.exit(1)

company_id = sys.argv[1]

jwt_token = get_jwt_token(env_vars)

if jwt_token:
    print("Authentication successful. Received JWT token.")

    company_data = get_company_data(company_id, jwt_token)

    if company_data:
        print("Company verification successful.")
        pretty_json = json.dumps(company_data, indent=2)
        print(pretty_json)
else:
    print("Failed to obtain JWT token. Exiting...")
