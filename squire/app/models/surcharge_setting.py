import uuid
from datetime import datetime
from sqlalchemy import String, Integer, Boolean, TIMESTAMP, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from . import Base

class SurchargeSetting(Base):
    __tablename__ = "surcharge_settings"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    barber_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("barbers.id"))
    type: Mapped[str] = mapped_column(String(20), nullable=False)
    max_value: Mapped[int] = mapped_column(Integer, nullable=False, default=50)
    min_value: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), default=datetime.utcnow)

    barber = relationship("Barber", back_populates="surcharge_settings") 