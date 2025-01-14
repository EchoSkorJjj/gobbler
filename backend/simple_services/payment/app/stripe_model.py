from pydantic import BaseModel

class EventData(BaseModel):
    object: object 
    previous_attributes: object = None

class StripeEvent(BaseModel):
    id: str
    api_version: str
    data: EventData
    request: object
    type: str
    object: str
    created: int
    livemode: bool
    pending_webhooks: int
