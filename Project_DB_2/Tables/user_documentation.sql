CREATE TABLE user_documentation (
    documentation_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES user_data(user_id),
    action_type VARCHAR(255),
    affected_row_id INTEGER,  -- Reference to the row in data_tags
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
