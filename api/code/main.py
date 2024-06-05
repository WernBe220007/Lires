from datetime import datetime, timedelta, timezone
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Security, status, Request
from fastapi.security import (
    OAuth2PasswordBearer,
    OAuth2PasswordRequestForm,
    SecurityScopes,
)
from fastapi.security.utils import get_authorization_scheme_param
from jose import JWTError, jwt
from pydantic import BaseModel, ValidationError
from token_handler import *
from database import *
from config import *

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
        "name": "GPL V3",
        "url": "https://github.com/WernBe220007/Lires/blob/main/LICENSE",
    },
    docs_url="/api/docs",
    redoc_url=None,
    openapi_url="/api/openapi.json",
    openapi_tags=tags_metadata,
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
        # msToken = req.headers["Authorization"]
        authorization = req.headers.get("Authorization")
        scheme, param = get_authorization_scheme_param(authorization)
        if not authorization or scheme.lower() != "bearer":
            raise HTTPException(
                status_code=401,
                detail="Not authenticated",
                headers={"WWW-Authenticate": "Bearer"},
            )
    except KeyError:
        raise HTTPException(
            status_code=401,
            detail="Token is missing",
            headers={"WWW-Authenticate": "Bearer"},
        )
    user = authenticate_user(param)
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(user.id), "scopes": ["me"]},
        expires_delta=access_token_expires,
    )
    return Token(access_token=access_token, token_type="bearer")


@app.get("/api/users/me/", response_model=User, tags=["users"])
async def read_users_me(
    current_user: Annotated[User, Depends(get_current_active_user)],
):
    return current_user


@app.get("/api/users/me/trips/", tags=["users"])
async def read_own_items(
    current_user: Annotated[User, Security(get_current_active_user, scopes=["me"])],
):
    return get_user_trips(current_user.id)


@app.get("/api/")
async def read_main():
    return {
        "msg": "Hello World",
    }


# example query:
# curl --insecure -X POST "https://localhost/api/trip/create" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{\"name\":\"Trip Name\",\"schoolyear\":\"2022\",\"startdate\":\"2022-01-01\",\"enddate\":\"2022-01-10\",\"disabled\":false}"
@app.post("/api/trip/create")
async def create_trip_ep(trip: Trip):
    create_trip(
        trip.name,
        trip.schoolyear,
        trip.startdate,
        trip.enddate,
        trip.disabled,
    )
    return {"msg": "OK"}


# example query:
# curl --insecure -X POST "https://localhost/api/trip/add_user" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{\"user_id\":\"1\",\"trip_id\":\"1\"}"
@app.post("/api/trip/add_user")
async def add_user_to_trip_ep(user_trip_link: UserTripLink):
    add_user_to_trip(user_trip_link.user_id, user_trip_link.trip_id)
    return {"msg": "OK"}


# example query:
# curl --insecure -X POST "https://localhost/api/trip/acknowledge?trip_id=1" -H  "accept: application/json" -H  "Content-Type: application/json"
@app.get("/api/users/me/trips/acknowledge")
async def acknowledge_my_trip(
    trip_id: str,
    current_user: Annotated[User, Depends(get_current_active_user)],
):
    acknowledge_trip(current_user.uid, trip_id)
    return {"msg": "OK"}
