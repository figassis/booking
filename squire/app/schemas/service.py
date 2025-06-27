from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from datetime import datetime

class ServiceBase(BaseModel):
    shop_id: UUID
    name: str
    description: Optional[str] = None
    price: int
    duration_minutes: int
    is_active: Optional[bool] = True

class ServiceCreate(ServiceBase):
    pass

class ServiceUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[int] = None
    duration_minutes: Optional[int] = None
    is_active: Optional[bool] = None

class ServiceResponse(ServiceBase):
    id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True 