from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from uuid import UUID
from typing import List

from ..database import get_db
from ..models.shop import Shop
from ..schemas.shop import ShopCreate, ShopUpdate, ShopResponse

router = APIRouter(prefix="/shops", tags=["shops"])

@router.post("/", response_model=ShopResponse, status_code=status.HTTP_201_CREATED)
async def create_shop(shop_in: ShopCreate, db: AsyncSession = Depends(get_db)):
    shop = Shop(**shop_in.model_dump())
    db.add(shop)
    await db.commit()
    await db.refresh(shop)
    return shop

@router.get("/", response_model=List[ShopResponse])
async def list_shops(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Shop))
    shops = result.scalars().all()
    return shops

@router.get("/{shop_id}", response_model=ShopResponse)
async def get_shop(shop_id: UUID, db: AsyncSession = Depends(get_db)):
    shop = await db.get(Shop, shop_id)
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found")
    return shop

@router.patch("/{shop_id}", response_model=ShopResponse)
async def update_shop(shop_id: UUID, shop_in: ShopUpdate, db: AsyncSession = Depends(get_db)):
    shop = await db.get(Shop, shop_id)
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found")
    for field, value in shop_in.model_dump(exclude_unset=True).items():
        setattr(shop, field, value)
    await db.commit()
    await db.refresh(shop)
    return shop

@router.delete("/{shop_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_shop(shop_id: UUID, db: AsyncSession = Depends(get_db)):
    shop = await db.get(Shop, shop_id)
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found")
    await db.delete(shop)
    await db.commit() 