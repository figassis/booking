from pydantic import BaseModel, EmailStr
from typing import Optional, List
from uuid import UUID
from datetime import datetime

class BarberBase(BaseModel):
    shop_id: UUID
    name: str
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    days_on: List[str]
    working_hours: list
    is_active: Optional[bool] = True

class BarberCreate(BarberBase):
    pass

class BarberUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    days_on: Optional[List[str]] = None
    working_hours: Optional[list] = None
    is_active: Optional[bool] = None

class BarberResponse(BarberBase):
    id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True 