import os

ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60 * 2))
SECRET_KEY = os.getenv("SECRET_KEY", os.urandom(16).hex())
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ISSUER = os.getenv("ISSUER", "https://localhost/api/token")
AUDIENCE = os.getenv("AUDIENCE", "https://localhost/api")
POSTGRES_USER = os.getenv("POSTGRES_USER", "postgres")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "postgres")
POSTGRES_SERVER = os.getenv("POSTGRES_SERVER", "postgres-api")
POSTGRES_DB = os.getenv("POSTGRES_DB", "postgres")
MS_ISSUER = os.getenv(
    "MS_ISSUER",
    "https://login.microsoftonline.com/88fae967-01b4-42f0-8966-32a990173948/v2.0",
)
MS_AUDIENCE = os.getenv("MS_AUDIENCE", "4f397fa9-b781-443c-8187-30ea6b940bc2")
MS_CACHE_EXPIRY = int(os.getenv("MS_CACHE_EXPIRY", 60 * 60 * 3))
