import uuid
from datetime import datetime
from sqlalchemy import String, Text, Boolean, TIMESTAMP, JSON, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from . import Base
from typing import List

class Barber(Base):
    __tablename__ = "barbers"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    shop_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("shops.id"))
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    email: Mapped[str] = mapped_column(String(255))
    phone: Mapped[str] = mapped_column(String(20))
    days_on: Mapped[List[str]] = mapped_column(ARRAY(Text), nullable=False, default=list)
    working_hours: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), default=datetime.utcnow)

    shop = relationship("Shop", back_populates="barbers")
    surcharge_settings = relationship("SurchargeSetting", back_populates="barber", cascade="all, delete-orphan")
    # appointments = relationship("Appointment", back_populates="barber", cascade="all, delete-orphan") 