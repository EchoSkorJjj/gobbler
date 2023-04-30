from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

load_dotenv()

DB_SERVER = os.getenv("DB_SERVER") or "127.0.0.1"
DB_PORT = os.getenv("DB_PORT") or '3306'
DB_USER = os.getenv("DB_USER") or 'root'
DB_PASSWORD = os.getenv("DB_PASSWORD") or 'root'
# DATABASE = os.getenv("DATABASE")
DATABASE = "reservation"

# pick one
# SQLALCHEMY_DATABASE_URI: str = (o
#     f"mysql+mysqldb://root:root@localhost:3306/{DATABASE}"
# )
# print(SQLALCHEMY_DATABASE_URI)

SQLALCHEMY_DATABASE_URI: str = (
    f"mysql+mysqldb://{DB_USER}:{DB_PASSWORD}@{DB_SERVER}:{DB_PORT}/{DATABASE}"
)
print(SQLALCHEMY_DATABASE_URI)

engine = create_engine(SQLALCHEMY_DATABASE_URI)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
