-- Enable the uuid-ossp extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS public.user_data (
    user_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    username1 VARCHAR(255),
    password1 VARCHAR(255)
);
