from typing import List

from fastapi import Depends, FastAPI, HTTPException, Response
from fastapi.responses import JSONResponse, RedirectResponse


from . import crud, schemas
from .stripe_model import StripeEvent


########### DO NOT MODIFY BELOW THIS LINE ###########

# create FastAPI app
app = FastAPI()


# catch all exceptions and return error message
@app.exception_handler(Exception)
async def all_exception_handler(request, exc):
    return JSONResponse(
        status_code=500, content={"message": request.url.path + " " + str(exc)}
    )


########### DO NOT MODIFY ABOVE THIS LINE ###########


@app.get("/ping")
def ping():
    """
    Health check endpoint
    """
    return {"ping": "pong!"}


@app.post("/createaccount", response_model=schemas.Account)
def create_account(user: schemas.UserCredentialsCreate):
    """
    Create a new account
    """
    created = crud.create_account(user)
    crud.create_auth(user)
    return created


@app.post("/loginuser", response_model=schemas.Account)
def login_user(user: schemas.UserCredentialsLogin, response: Response):
    """
    Logs in user using username and password, returns user account object with bearer token in header.
    """

    token = crud.get_token(user)
    print(token)
    # set return header to have the auth bearer token
    response.headers["Authorization"] = token

    user = crud.get_user_by_email(
        user.username
    )  # username is actually email in this case, don't question it

    return user


@app.post("/subscribe")
def create_subscription(checkout_request: schemas.SubscribeRequest):
    redirect_url = crud.subscribe(
        user_id=checkout_request.userId, success_url=checkout_request.success_url
    )

    return {"stripe_checkout_url": redirect_url}


@app.patch("/user/{user_id}", response_model=schemas.Account)
def update_user(user_id: int, update_data: schemas.AccountUpdate):
    user = crud.get_account(user_id)
    return crud.update_account(user_id, update_data)


@app.post("/webhook")
async def process_webhook(event: StripeEvent):
    """
    Forward Stripe webhook to payment service
    """
    webhook_secret = (
        ""  # TODO - set up secret validation for webhook to filter out spoofed requests
    )
    print("Webhook received: " + str(event.__dict__))
    paid_user = crud.process_webhook(event)
    if paid_user:
        crud.update_account(paid_user["userId"], schemas.AccountUpdate(isPremium=True))
