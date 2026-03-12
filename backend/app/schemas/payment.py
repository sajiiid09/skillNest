from datetime import datetime

from pydantic import BaseModel, ConfigDict


class PaymentCreate(BaseModel):
    task_id: int


class PaymentRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    task_id: int
    buyer_id: int
    developer_id: int
    amount: float
    currency: str
    provider: str
    provider_payment_id: str
    status: str
    paid_at: datetime
