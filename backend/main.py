from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from pricing import calculate_price

app = FastAPI()

# Enable CORS for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class PricingRequest(BaseModel):
    vehicle: str
    distance: float
    load: float
    route: str
    time_type: str


@app.get("/")
def home():
    return {
        "message": "Dynamic Pricing Engine Running"
    }


@app.post("/calculate")
def calculate(data: PricingRequest):

    pricing = calculate_price(
        vehicle=data.vehicle,
        distance=data.distance,
        load=data.load,
        route=data.route,
        time_type=data.time_type
    )

    return {
        "success": True,
        "pricing": pricing
    }

