import uuid
from sqlalchemy import Column, DateTime, ForeignKey, Numeric
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.core.database import Base
class WeightLog(Base):
    __tablename__ = "weight_logs"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    weight_lbs = Column(Numeric(5, 2), nullable=False)
    logged_at = Column(DateTime(timezone=True), nullable=False)
    user = relationship("User", back_populates="weight_logs")