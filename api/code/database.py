from uuid import uuid4
from sqlmodel import SQLModel, Session, create_engine, select, Field
from pydantic import UUID4
from typing import Optional

engine = create_engine("postgresql://postgres:postgres@postgres-api/postgres")

class User(SQLModel, table=True):
    id: UUID4 = Field(default_factory=uuid4, primary_key=True)
    name: str
    pref_name: str
    disabled: bool
    scopes_string: Optional[str] = Field("me", alias="scopes")

    @property
    def scopes(self) -> list[str]:
        return self.scopes_string.split(',')

    @scopes.setter
    def scopes(self, scopes: list[str]):
        self.scopes_string = ','.join(scopes)

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

def clear_user_scopes(id:str):
    with Session(engine) as session:
        statement = select(User).where(User.id == id)
        result = session.exec(statement)
        user = result.one()
        user.scopes = "me"
        session.add(user)
        session.commit()
        session.refresh(user)
        return user