from uuid import uuid4
from sqlmodel import SQLModel, Session, create_engine, select, Field, Relationship
from pydantic import UUID4
from typing import Optional
from config import *
from enum import Enum
from datetime import datetime

engine = create_engine(
    f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_SERVER}/{POSTGRES_DB}"
)


class privelege(Enum):
    admin = "admin"
    av = "av"
    teacher = "teacher"
    student = "student"


def create_db_uid():
    return str(uuid4())

class UserTripLink(SQLModel, table=True):
    user_id: UUID4 = Field(foreign_key="user.uid", primary_key=True)
    trip_id: UUID4 = Field(foreign_key="trip.uid", primary_key=True)
    acknowledged: bool = False

    user: "User" = Relationship(back_populates="trip_links")
    trip: "Trip" = Relationship(back_populates="students")

class User(SQLModel, table=True):
    uid: UUID4 = Field(default_factory=uuid4, primary_key=True)
    id: str = Field(default_factory=create_db_uid, unique=True, index=True)
    name: str
    pref_name: str
    disabled: bool
    scopes_string: Optional[str] = Field("me", alias="scopes")
    privelege_level: privelege = privelege.student
    trip_links: list[UserTripLink] = Relationship(back_populates="user")

    @property
    def scopes(self) -> list[str]:
        return self.scopes_string.split(",")

    @scopes.setter
    def scopes(self, scopes: list[str]):
        self.scopes_string = ",".join(scopes)


class Trip(SQLModel, table=True):
    uid: UUID4 = Field(default_factory=uuid4, primary_key=True)
    id: str = Field(default_factory=create_db_uid, unique=True, index=True)
    name: str
    schoolyear: datetime
    startdate: datetime
    enddate: datetime
    disabled: bool
    students: list[UserTripLink] = Relationship(back_populates="trip")
    #effected_teachers: list[User] = Relationship(back_populates="trip")
    #responsible_av: User = Relationship(back_populates="trip")
    #accompanying: list[User] = Relationship(back_populates="trip")
    #leader: User = Relationship(back_populates="trip")
#    costs: bool
#    costs_teacher: float
#    costs_student: float
#    costs_daily: float
#    costs_travel: float
#    costs_via_businesscard: bool
#    costs_businesscard: bool

#class UserTrip(SQLModel, table=True):
#    id: int = Field(default_factory=int, primary_key=True)
#    user: Optional[User] = Relationship(back_populates="user_trips")
#    trip: Optional[Trip] = Relationship(back_populates="trip_users")
#    acknowledged: bool
#    decision_date: datetime


def create_user(name: str, pref_name: str, disabled: bool):
    with Session(engine) as session:
        user = User(name=name, pref_name=pref_name, disabled=disabled)
        session.add(user)
        session.commit()
        session.refresh(user)
        return user


def get_user_by_id(id: str):
    with Session(engine) as session:
        statement = select(User).where(User.id == id)
        result = session.exec(statement)
        return result.one_or_none()


def get_user_by_name(pref_name: str):
    with Session(engine) as session:
        statement = select(User).where(User.pref_name == pref_name)
        result = session.exec(statement)
        return result.one_or_none()


def get_users():
    with Session(engine) as session:
        statement = select(User)
        result = session.exec(statement)
        return result.all()


def get_user_scopes(id: str):
    with Session(engine) as session:
        statement = select(User).where(User.id == id)
        result = session.exec(statement)
        return result.one().scopes


def add_user_scope(id: str, scope: str):
    with Session(engine) as session:
        statement = select(User).where(User.id == id)
        result = session.exec(statement)
        user = result.one()
        user.scopes.append(scope)
        session.add(user)
        session.commit()
        session.refresh(user)
        return user


def remove_user_scope(id: str, scope: str):
    with Session(engine) as session:
        statement = select(User).where(User.id == id)
        result = session.exec(statement)
        user = result.one()
        user.scopes.remove(scope)
        session.add(user)
        session.commit()
        session.refresh(user)
        return user


def clear_user_scopes(id: str):
    with Session(engine) as session:
        statement = select(User).where(User.id == id)
        result = session.exec(statement)
        user = result.one()
        user.scopes = "me"
        session.add(user)
        session.commit()
        session.refresh(user)
        return user
    
def reset_user_privelege(id: str):
    with Session(engine) as session:
        statement = select(User).where(User.id == id)
        result = session.exec(statement)
        user = result.one()
        user.privelege_level = privelege.student
        session.add(user)
        session.commit()
        session.refresh(user)
        return user

def set_user_privelege(id: str, privelege_level: privelege):
    with Session(engine) as session:
        statement = select(User).where(User.id == id)
        result = session.exec(statement)
        user = result.one()
        user.privelege_level = privelege_level
        session.add(user)
        session.commit()
        session.refresh(user)
        return user
    
def create_trip(name: str, schoolyear: datetime, startdate: datetime, enddate: datetime, disabled: bool):
    with Session(engine) as session:
        trip = Trip(name=name, schoolyear=datetime.now(), startdate=datetime.now(), enddate=datetime.now(), disabled=disabled, students=[])
        session.add(trip)
        session.commit()
        session.refresh(trip)
        return trip
    
def add_user_to_trip(user_id: str, trip_id: str):
    with Session(engine) as session:
        statement = select(User).where(User.id == user_id)
        result = session.exec(statement)
        user = result.one()
        statement = select(Trip).where(Trip.id == trip_id)
        result = session.exec(statement)
        trip = result.one()
        link = UserTripLink(user_id=user.uid, trip_id=trip.uid)
        session.add(link)
        session.commit()
        session.refresh(link)
        return link
    
def get_user_trips(user_id: str):
    with Session(engine) as session:
        statement = select(User).where(User.id == user_id)
        result = session.exec(statement)
        user = result.one()
        return user.students
    
def get_trip_users(trip_id: str):
    with Session(engine) as session:
        statement = select(Trip).where(Trip.id == trip_id)
        result = session.exec(statement)
        trip = result.one()
        return trip.students
    
def acknowledge_trip(user_id: str, trip_id: str):
    with Session(engine) as session:
        statement = select(UserTripLink).where(UserTripLink.user_id == user_id).where(UserTripLink.trip_id == trip_id)
        result = session.exec(statement)
        link = result.one()
        link.acknowledged = True
        session.add(link)
        session.commit()
        session.refresh(link)
        return link