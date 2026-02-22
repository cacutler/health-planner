import uuid
from sqlalchemy import Column, String, Integer, DateTime, Enum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.core.database import Base
import enum
class SexType(str, enum.Enum):
    male = "male"
    female = "female"
class ActivityLevel(str, enum.Enum):
    sedentary = "sedentary"
    light = "light"
    moderate = "moderate"
    active = "active"
class User(Base):
    __tablename__ = "users"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    height_in = Column(Integer)
    weight_lbs = Column(Integer)
    age = Column(Integer)
    sex = Column(Enum(SexType))
    activity__level = Column(Enum(ActivityLevel))
    created_at = Column(DateTime(timezone=True), server_default=func.now())