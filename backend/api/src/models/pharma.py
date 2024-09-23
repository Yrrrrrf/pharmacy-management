from pydantic import BaseModel, Field
from typing import List, Optional
from enum import Enum


    # * CHECK 5.21 LABELLING OF SECONDARY PACKAGING
    # * CHECK 5.21 LABELLING OF SECONDARY PACKAGING
    # * CHECK 5.21 LABELLING OF SECONDARY PACKAGING


class DrugType(Enum):
    PATENT = "Patent"
    GENERIC = "Generic"

class DrugNature(Enum):
    ALLOPATHIC = "Allopathic"
    HOMEOPATHIC = "Homeopathic"

class Commercialization(Enum):
    PRESCRIPTION = "Prescription"
    OVER_THE_COUNTER = "Over the Counter"
    CONTROLLED = "Controlled"
    INVESTIGATIONAL = "Investigational"
    BOTANICAL = "Botanical"
    ORPHAN = "Orphan"

class Pathology(BaseModel):
    name: str
    description: Optional[str] = None

class PharmaEffect(BaseModel):
    name: str
    description: str

class Pharmaceutical(BaseModel):
    name: str = Field(..., description="Name of the pharmaceutical")
    type: DrugType
    nature: DrugNature
    commercialization: Commercialization
    patologies: List[Pathology] = Field(..., description="List of pathologies the pharmaceutical is used to treat")


    # todo: add some decorator to use the enable as another field (like a property)
    # todo: do not use @property, instead use some pydantic decorator
    # todo: this way, the field can be used as a property and as a field
    def effects(self) -> List[PharmaEffect]:
        return []
