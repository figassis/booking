from fastapi import FastAPI
from .api.shops import router as shops_router
from .api.barbers import router as barbers_router
from .api.services import router as services_router
from .api.appointments import router as appointments_router
from .api.customers import router as customers_router
from .api.surcharge_settings import router as surcharge_settings_router

app = FastAPI(title="Barber Booking SaaS API")

app.include_router(shops_router)
app.include_router(barbers_router)
app.include_router(services_router)
app.include_router(appointments_router)
app.include_router(customers_router)
app.include_router(surcharge_settings_router)

# Routers will be included here 
