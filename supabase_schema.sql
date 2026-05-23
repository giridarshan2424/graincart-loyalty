-- Create Customers Table
CREATE TABLE customers (
  phone_number VARCHAR(15) PRIMARY KEY,
  customer_name VARCHAR(255) NOT NULL,
  total_purchases INTEGER DEFAULT 0,
  rewards_earned INTEGER DEFAULT 0,
  rewards_redeemed INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  last_visit TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create Purchases Table
CREATE TABLE purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_phone VARCHAR(15) REFERENCES customers(phone_number) ON DELETE CASCADE,
  purchase_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  added_by_admin VARCHAR(255) DEFAULT 'admin',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create Rewards Table
CREATE TABLE rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_phone VARCHAR(15) REFERENCES customers(phone_number) ON DELETE CASCADE,
  reward_status VARCHAR(50) DEFAULT 'unlocked', -- 'unlocked', 'redeemed'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  redeemed_at TIMESTAMP WITH TIME ZONE
);

-- Function to handle purchase addition and increment customer total_purchases
CREATE OR REPLACE FUNCTION increment_customer_purchases()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE customers
  SET total_purchases = total_purchases + 1,
      last_visit = CURRENT_TIMESTAMP
  WHERE phone_number = NEW.customer_phone;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to increment customer purchases
CREATE TRIGGER tr_increment_purchases
BEFORE INSERT ON purchases
FOR EACH ROW
EXECUTE FUNCTION increment_customer_purchases();

-- Create Function to trigger reward creation on every 5 purchases
CREATE OR REPLACE FUNCTION check_and_unlock_reward()
RETURNS TRIGGER AS $$
DECLARE
  v_total_purchases INTEGER;
  v_rewards_earned INTEGER;
BEGIN
  SELECT total_purchases, rewards_earned 
  INTO v_total_purchases, v_rewards_earned
  FROM customers 
  WHERE phone_number = NEW.customer_phone;

  IF (v_total_purchases / 5) > v_rewards_earned THEN
    INSERT INTO rewards (customer_phone, reward_status)
    VALUES (NEW.customer_phone, 'unlocked');
    
    UPDATE customers 
    SET rewards_earned = rewards_earned + 1 
    WHERE phone_number = NEW.customer_phone;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to run the function after a new purchase is inserted
CREATE TRIGGER tr_check_reward
AFTER INSERT ON purchases
FOR EACH ROW
EXECUTE FUNCTION check_and_unlock_reward();
