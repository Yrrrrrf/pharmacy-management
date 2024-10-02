from pydantic import BaseModel, Field
from typing import List, Optional
from .pharma import Pharmaceutical

class PharmaceuticalForm(BaseModel):
    name: str = Field(..., description="Name of the pharmaceutical form")
    description: Optional[str] = None

class AdministrationRoute(BaseModel):
    name: str
    description: Optional[str] = None

class UsageConsideration(BaseModel):
    name: str
    description: Optional[str] = None

class PharmaceuticalProduct(BaseModel):
    pharmaceutical: Pharmaceutical = Field(...)
    form: PharmaceuticalForm = Field(...)
    administration_routes: List[AdministrationRoute] = Field(...)
    usage_considerations: List[UsageConsideration] = Field(...)


    # * Pharmaceutical (in physical form concentration)
    concentration: str = Field(..., description="Concentration of the pharmaceutical")

    # * ALL products
    expiration_date: str = Field(..., description="Expiration date of the pharmaceutical")
    price: float = Field(..., description="Price of the pharmaceutical")

    # * metadata (auxiliar fields)
    stock: int = Field(..., description="Stock of the pharmaceutical (count)")

    # * (5.5) CHECK HOW TO HANDLE THIS FIELD
    # conservation: str = Field(..., description="Conservation of the pharmaceutical")
