from database import engine
from sqlalchemy import text

with engine.connect() as conn:
    conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS age INTEGER"))
    conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS height FLOAT"))
    conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS weight FLOAT"))
    conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS gender VARCHAR"))
    conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS fitness_goal VARCHAR"))
    conn.commit()
    print("✅ Columns added successfully!")