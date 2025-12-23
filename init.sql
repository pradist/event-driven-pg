-- 1. Create table to store orders
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Create function to send NOTIFY
-- This function is called by a trigger after an INSERT
CREATE OR REPLACE FUNCTION notify_new_order()
RETURNS TRIGGER AS $$
DECLARE
     -- Build JSON payload from the new row (NEW)
    payload TEXT;
BEGIN
    payload := json_build_object(
        'id', NEW.id,
        'customer_name', NEW.customer_name,
        'amount', NEW.amount,
        'created_at', NEW.created_at,
        'action', TG_OP -- 'INSERT'
    )::TEXT;

     -- Send notification to the 'new_order' channel with the payload
    PERFORM pg_notify('new_order', payload);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Create trigger to call the function when a new row is inserted into orders
CREATE TRIGGER order_inserted_trigger
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION notify_new_order();
