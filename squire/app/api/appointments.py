from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from uuid import UUID
from typing import List

from ..database import get_db
from ..models.appointment import Appointment
from ..schemas.appointment import AppointmentCreate, AppointmentUpdate, AppointmentResponse

router = APIRouter(prefix="/appointments", tags=["appointments"])

@router.post("/", response_model=AppointmentResponse, status_code=status.HTTP_201_CREATED)
async def create_appointment(appointment_in: AppointmentCreate, db: AsyncSession = Depends(get_db)):
    appointment = Appointment(**appointment_in.model_dump())
    db.add(appointment)
    await db.commit()
    await db.refresh(appointment)
    return appointment

@router.get("/", response_model=List[AppointmentResponse])
async def list_appointments(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Appointment))
    appointments = result.scalars().all()
    return appointments

@router.get("/{appointment_id}", response_model=AppointmentResponse)
async def get_appointment(appointment_id: UUID, db: AsyncSession = Depends(get_db)):
    appointment = await db.get(Appointment, appointment_id)
    if not appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
    return appointment

@router.patch("/{appointment_id}", response_model=AppointmentResponse)
async def update_appointment(appointment_id: UUID, appointment_in: AppointmentUpdate, db: AsyncSession = Depends(get_db)):
    appointment = await db.get(Appointment, appointment_id)
    if not appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
    for field, value in appointment_in.model_dump(exclude_unset=True).items():
        setattr(appointment, field, value)
    await db.commit()
    await db.refresh(appointment)
    return appointment

@router.delete("/{appointment_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_appointment(appointment_id: UUID, db: AsyncSession = Depends(get_db)):
    appointment = await db.get(Appointment, appointment_id)
    if not appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
    await db.delete(appointment)
    await db.commit() 