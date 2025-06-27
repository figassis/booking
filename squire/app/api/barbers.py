from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from uuid import UUID
from typing import List

from ..database import get_db
from ..models.barber import Barber
from ..schemas.barber import BarberCreate, BarberUpdate, BarberResponse

router = APIRouter(prefix="/barbers", tags=["barbers"])

@router.post("/", response_model=BarberResponse, status_code=status.HTTP_201_CREATED)
async def create_barber(barber_in: BarberCreate, db: AsyncSession = Depends(get_db)):
    barber = Barber(**barber_in.model_dump())
    db.add(barber)
    await db.commit()
    await db.refresh(barber)
    return barber

@router.get("/", response_model=List[BarberResponse])
async def list_barbers(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Barber))
    barbers = result.scalars().all()
    return barbers

@router.get("/{barber_id}", response_model=BarberResponse)
async def get_barber(barber_id: UUID, db: AsyncSession = Depends(get_db)):
    barber = await db.get(Barber, barber_id)
    if not barber:
        raise HTTPException(status_code=404, detail="Barber not found")
    return barber

@router.patch("/{barber_id}", response_model=BarberResponse)
async def update_barber(barber_id: UUID, barber_in: BarberUpdate, db: AsyncSession = Depends(get_db)):
    barber = await db.get(Barber, barber_id)
    if not barber:
        raise HTTPException(status_code=404, detail="Barber not found")
    for field, value in barber_in.model_dump(exclude_unset=True).items():
        setattr(barber, field, value)
    await db.commit()
    await db.refresh(barber)
    return barber

@router.delete("/{barber_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_barber(barber_id: UUID, db: AsyncSession = Depends(get_db)):
    barber = await db.get(Barber, barber_id)
    if not barber:
        raise HTTPException(status_code=404, detail="Barber not found")
    await db.delete(barber)
    await db.commit() 