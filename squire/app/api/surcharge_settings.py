from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from uuid import UUID
from typing import List

from ..database import get_db
from ..models.surcharge_setting import SurchargeSetting
from ..schemas.surcharge_setting import SurchargeSettingCreate, SurchargeSettingUpdate, SurchargeSettingResponse

router = APIRouter(prefix="/barbers/{barber_id}/surcharges", tags=["surcharge_settings"])

@router.post("/", response_model=SurchargeSettingResponse, status_code=status.HTTP_201_CREATED)
async def create_surcharge_setting(barber_id: UUID, surcharge_in: SurchargeSettingCreate, db: AsyncSession = Depends(get_db)):
    surcharge = SurchargeSetting(**surcharge_in.model_dump(), barber_id=barber_id)
    db.add(surcharge)
    await db.commit()
    await db.refresh(surcharge)
    return surcharge

@router.get("/", response_model=List[SurchargeSettingResponse])
async def list_surcharge_settings(barber_id: UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(SurchargeSetting).where(SurchargeSetting.barber_id == barber_id))
    surcharges = result.scalars().all()
    return surcharges

@router.get("/{surcharge_id}", response_model=SurchargeSettingResponse)
async def get_surcharge_setting(barber_id: UUID, surcharge_id: UUID, db: AsyncSession = Depends(get_db)):
    surcharge = await db.get(SurchargeSetting, surcharge_id)
    if not surcharge or surcharge.barber_id != barber_id:
        raise HTTPException(status_code=404, detail="Surcharge setting not found")
    return surcharge

@router.patch("/{surcharge_id}", response_model=SurchargeSettingResponse)
async def update_surcharge_setting(barber_id: UUID, surcharge_id: UUID, surcharge_in: SurchargeSettingUpdate, db: AsyncSession = Depends(get_db)):
    surcharge = await db.get(SurchargeSetting, surcharge_id)
    if not surcharge or surcharge.barber_id != barber_id:
        raise HTTPException(status_code=404, detail="Surcharge setting not found")
    for field, value in surcharge_in.model_dump(exclude_unset=True).items():
        setattr(surcharge, field, value)
    await db.commit()
    await db.refresh(surcharge)
    return surcharge

@router.delete("/{surcharge_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_surcharge_setting(barber_id: UUID, surcharge_id: UUID, db: AsyncSession = Depends(get_db)):
    surcharge = await db.get(SurchargeSetting, surcharge_id)
    if not surcharge or surcharge.barber_id != barber_id:
        raise HTTPException(status_code=404, detail="Surcharge setting not found")
    await db.delete(surcharge)
    await db.commit() 