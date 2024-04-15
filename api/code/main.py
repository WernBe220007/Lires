from datetime import datetime, timedelta, timezone
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Security, status, Request
from fastapi.security import (
    OAuth2PasswordBearer,
    OAuth2PasswordRequestForm,
    SecurityScopes,
)
from jose import JWTError, jwt
from pydantic import BaseModel, ValidationError
from token_handler import *
from database import *

tags_metadata = [
    {
        "name": "users",
        "description": "Operations with users. Login, Changing Permissiosn and Granting tokens.",
    },
    {
        "name": "items",
        "description": "Manage items.",
    },
]


app = FastAPI(
    title="LiRes",
    description="This is the API Backend for the LiRes Application.",
    summary="LiRes API",
    version="0.0.1",
    license_info={
        "name": "Undecided",
        "url": "https://litec.ac.at",
    },
    docs_url="/api/docs", 
    redoc_url=None,
    openapi_url="/api/openapi.json",
    openapi_tags=tags_metadata
)

def on_startup():
    SQLModel.metadata.create_all(engine)
app.add_event_handler("startup", on_startup)

async def get_current_active_user(
    current_user: Annotated[User, Security(get_current_user, scopes=["me"])],
):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

@app.get("/api/token")
async def login_for_access_token(req: Request) -> Token:
    try:
        msToken = req.headers["Authorization"]
    except KeyError:
        raise HTTPException(status_code=401, detail="Token is missing")
    user = authenticate_user(msToken)
    print(user)
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(user.id), "scopes": "me"},
        expires_delta=access_token_expires,
    )
    return Token(access_token=access_token, token_type="bearer")


@app.get("/api/users/me/", response_model=User, tags=["users"])
async def read_users_me(
    current_user: Annotated[User, Depends(get_current_active_user)],
):
    return current_user


@app.get("/api/users/me/items/", tags=["users"])
async def read_own_items(
    current_user: Annotated[User, Depends(get_current_active_user)],
):
    return [{"item_id": "Foo", "owner": current_user.username}]


@app.get("/api/")
async def read_main():
    return {"msg": "Hello World"}