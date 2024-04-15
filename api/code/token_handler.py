from datetime import datetime, timedelta, timezone
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Security, status
from fastapi.security import (
    OAuth2PasswordBearer,
    OAuth2PasswordRequestForm,
    SecurityScopes,
)
from jose import JWTError, jwt
from pydantic import BaseModel, ValidationError
from database import *
import requests
import OpenSSL.crypto
import json
import time

ACCESS_TOKEN_EXPIRE_MINUTES = 30
SECRET_KEY = "4810eb636b96664a31388d97b47e335c0708c4caf6d0e9fec9355e8b0883d9d8"
ALGORITHM = "HS256"

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="api/token",
    scopes={
        "me": "Read information about the current user.",
        "items": "Read items."
    },
)


class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: str | None = None
    scopes: list[str] = []


ISSUER = "https://login.microsoftonline.com/88fae967-01b4-42f0-8966-32a990173948/v2.0"
AUDIENCE = "4f397fa9-b781-443c-8187-30ea6b940bc2"
EXPIRY = 60 * 60 * 3  # 3 hours
keys = None
last_fetch_time = 0

def fetch_keys():
    global keys, last_fetch_time
    if keys is not None and time.time() - last_fetch_time < EXPIRY:
        return keys
    else:
        response = requests.get('https://login.microsoftonline.com/common/discovery/keys')
        keys = json.loads(response.text)['keys']
        last_fetch_time = time.time()
        return keys

def authenticate_user(mstoken: str):
    
    keys = fetch_keys()

    # Find the key that matches the kid in the token header
    try:
        header = jwt.get_unverified_header(mstoken)
    except JWTError:
        raise HTTPException(status_code=400, detail="Invalid token")
    
    try:
        key = next((key for key in keys if key['kid'] == header['kid']), None)
    except KeyError:
        raise HTTPException(status_code=400, detail="Invalid token")

    # Extract the public key from the certificate
    try:
        cert_str = key['x5c'][0]
    except KeyError:
        raise HTTPException(status_code=400, detail="Invalid token")
    
    cert_str = "-----BEGIN CERTIFICATE-----\n" + cert_str + "\n-----END CERTIFICATE-----"

    # Load the public key
    try:
        cert_obj = OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_PEM, cert_str)
        public_key = OpenSSL.crypto.dump_publickey(OpenSSL.crypto.FILETYPE_PEM, cert_obj.get_pubkey())
    except OpenSSL.crypto.Error:
        raise HTTPException(status_code=500, detail="Error loading certificate")

    try:
        payload = jwt.decode(mstoken, key=public_key, algorithms=["RS256"], audience=AUDIENCE, issuer=ISSUER)
    except JWTError:
        raise HTTPException(status_code=400, detail="Invalid token")
    
    # Extract preferred name from token
    try:
        pref_name = payload['preferred_username']
        name = payload['name']
    except KeyError:
        raise HTTPException(status_code=400, detail="Invalid token")
    
    # Check if user is already in database
    user = get_user_by_name(pref_name)
    if user is None:
        # Create
        user = create_user(name, pref_name, False)
        print("Registered new user")
    print("Authenticated user")
    return user
    
    

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(
    security_scopes: SecurityScopes, token: Annotated[str, Depends(oauth2_scheme)]
):
    print("Getting current user")
    if security_scopes.scopes:
        authenticate_value = f'Bearer scope="{security_scopes.scope_str}"'
    else:
        authenticate_value = "Bearer"
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": authenticate_value},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_scopes = payload.get("scopes", [])
        token_data = TokenData(scopes=token_scopes, username=username)
    except (JWTError, ValidationError):
        raise credentials_exception
    user = get_user_by_id(token_data.username)
    if user is None:
        raise credentials_exception
    for scope in security_scopes.scopes:
        if scope not in token_data.scopes:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Not enough permissions",
                headers={"WWW-Authenticate": authenticate_value},
            )
    return user