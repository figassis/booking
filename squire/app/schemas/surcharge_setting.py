from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from datetime import datetime

class SurchargeSettingBase(BaseModel):
    barber_id: UUID
    type: str
    max_value: int
    min_value: int
    is_active: Optional[bool] = True

class SurchargeSettingCreate(SurchargeSettingBase):
    pass

class SurchargeSettingUpdate(BaseModel):
    type: Optional[str] = None
    max_value: Optional[int] = None
    min_value: Optional[int] = None
    is_active: Optional[bool] = None

class SurchargeSettingResponse(SurchargeSettingBase):
    id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True 