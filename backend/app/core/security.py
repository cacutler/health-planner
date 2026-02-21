from datetime import datetime, timedelta, UTC
from jose import jwt
from passlib.context import CryptContext
import os
SECRET_KEY = os.getenv("SECRET_KET", "dev-secret")
ALGORITHM = "HS256"
ACCESS_TOEKN_EXPIRE_MINUTES = 30
pwd_context = CryptContext(schemes=["bcrypt"], depreated="auto")
def hash_password(password: str) -> str:
    return pwd_context.hash(password)
def verify_password(password: str, hashed: str) -> bool:
    return pwd_context.verify(password, hashed)
def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(UTC) + timedelta(minutes=ACCESS_TOEKN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)