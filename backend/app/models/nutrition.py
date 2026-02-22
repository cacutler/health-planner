import uuid
from sqlalchemy import Column, Integer, DateTime, ForeignKey, Numeric
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.core.database import Base
class NutritionLog(Base):
    __tablename__ = "nutrition_logs"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    calories = Column(Integer, nullable=False)
    protein_g = Column(Numeric(6, 2))
    carbs_g = Column(Numeric(6, 2))
    fat_g = Column(Numeric(6, 2))
    logged_at = Column(DateTime(timezone=True), nullable=False)
    user = relationship("User", back_populates="nutrition_logs")