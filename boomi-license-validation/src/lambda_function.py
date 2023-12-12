from __future__ import print_function
import logging
import requests
import urllib3
import json
import copy

logger = logging.getLogger(__name__)

def _create_auth_headers(username, password, account):
    headers = {'Content-Type': 'application/json',
               'Accept': 'application/json'}
    headers.update(urllib3.util.make_headers(
        basic_auth=f"{username}:{password}"))
    return headers

def _verify_boomi_licensing(username, password, account):
    _headers = _create_auth_headers(username, password, account)
    API_URL = f"https://api.boomi.com/api/rest/v1/{account}/Account/{account}"
    resp = requests.get(API_URL, headers=_headers)
    resp.raise_for_status()
    json_resp = resp.json()

    account_status = json_resp['status']
    molecule_licenses_purchased = json_resp['molecule']['purchased']
    molecule_licenses_used = json_resp['molecule']['used']
    print(molecule_licenses_used)

    # Is the account active?
    if account_status == 'active':
        logger.info(f"Account is active")
    else:
        logger.error('Exception: Boomi account is inactive')
        raise Exception(f"Boomi account {account} is inactive.")

    # Do we have license entitelements at all?
    if molecule_licenses_purchased > molecule_licenses_used:
        logger.info(
            f"Licenses are available - Purchased: {molecule_licenses_purchased} / Used: {molecule_licenses_used}")
    else:
        logger.error('Exception: No molecule license available')
        raise Exception(
            f"No molecule licenses for account {account} are available. Purchased: {molecule_licenses_purchased}, Used: {molecule_licenses_used}")
            
def _verify_required_parameters(parameters):
    REQUIRED = ['BoomiUsername', 'BoomiPassword',
                'BoomiAccountID', 'TokenType', 'TokenTimeout']
    REQ_TOKEN_TYPES = ['MOLECULE']
    for req_param in REQUIRED:
        if req_param not in parameters.keys():
            raise Exception(
                f"Not all required parameters have been passed. Need: {str(REQUIRED)}")
    if parameters['TokenType'].upper() not in REQ_TOKEN_TYPES:
        raise Exception(
            f"Parameter TokenType must be one of: {str(REQ_TOKEN_TYPES)}")
    if not parameters['BoomiUsername'].startswith("BOOMI_TOKEN."):
        _r = (
            parameters['BoomiUsername'],
            parameters['BoomiPassword'],
            parameters['BoomiAccountID'], None, None
        )
        return _r
    _r = (
        parameters['BoomiUsername'],
        parameters['BoomiPassword'],
        parameters['BoomiAccountID'],
        parameters['TokenType'].upper(),
        parameters['TokenTimeout']
    )
    return _r

def _generate_install_token(username, password, account_id, token_type, timeout):
    _headers = _create_auth_headers(username, password, account_id)
    API_URL = f"https://api.boomi.com/api/rest/v1/{account_id}/InstallerToken/"
    payload = {
        "installType": token_type,
        "durationMinutes": int(timeout)
    }
    logger.info(payload)
    resp = requests.post(API_URL, headers=_headers, json=payload)
    resp.raise_for_status()
    rj = resp.json()

    return rj['token']

def auth_and_licensing_logic(event, context):
    sanitized_event = copy.deepcopy(event)
    sanitized_event['ResourceProperties']['BoomiPassword'] = "<Redacted>"
    logger.info('Received event: %s' % json.dumps(sanitized_event))

    # Sanity Checking
    parameters = event['ResourceProperties']
    username, password, account_id, token_type, token_timeout = _verify_required_parameters(
        parameters)

    # Verify licensing
    _verify_boomi_licensing(username, password, account_id)
    if token_type:
        # Generate install token
        token = _generate_install_token(
            username, password, account_id, token_type, token_timeout)
        return token

def lambda_handler(event, context):
    token = auth_and_licensing_logic(event, context)
    return {
            'token': token
        }