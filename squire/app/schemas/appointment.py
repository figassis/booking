from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from datetime import datetime

class AppointmentBase(BaseModel):
    barber_id: UUID
    customer_id: UUID
    service_id: UUID
    appointment_date: datetime
    duration_minutes: int
    price: int
    discount: Optional[int] = 0
    booking_fee: Optional[int] = 0
    surcharge: Optional[int] = 0
    status: Optional[str] = "scheduled"
    notes: Optional[str] = None

class AppointmentCreate(AppointmentBase):
    pass

class AppointmentUpdate(BaseModel):
    appointment_date: Optional[datetime] = None
    duration_minutes: Optional[int] = None
    price: Optional[int] = None
    discount: Optional[int] = None
    booking_fee: Optional[int] = None
    surcharge: Optional[int] = None
    status: Optional[str] = None
    notes: Optional[str] = None

class AppointmentResponse(AppointmentBase):
    id: UUID
    total_price: Optional[int] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True 