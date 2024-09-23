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
    concentration: str = Field(..., description="Concentration of the pharmaceutical")



    usage_considerations: List[UsageConsideration] = Field(...)
    administration_routes: List[AdministrationRoute] = Field(...)

    # * additional fields (auxiliar ones...)
    # dosage: str
    # price: float (can be generated once te product is created...)
    # stock: int (get it from the inventory)
    # * (5.5) CHECK HOW TO HANDLE THIS FIELD
    # conservation: str = Field(..., description="Conservation of the pharmaceutical")
