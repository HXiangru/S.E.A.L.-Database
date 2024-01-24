CREATE TABLE IF NOT EXISTS public.user_data
(
    user_id uuid NOT NULL DEFAULT uuid_generate_v4(),
    username1 character varying(255) COLLATE pg_catalog."default",
    password1 character varying(255) COLLATE pg_catalog."default",
    "Admin" boolean,
    CONSTRAINT user_data_pkey PRIMARY KEY (user_id)
)