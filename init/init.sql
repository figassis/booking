-- Barber Booking SaaS Database Schema

-- Shops table
CREATE TABLE shops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    timezone VARCHAR(50) DEFAULT 'UTC',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Barbers table
CREATE TABLE barbers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    days_on TEXT[] NOT NULL DEFAULT '{}', -- Array of: monday, tuesday, wednesday, thursday, friday, saturday, sunday
    working_hours JSONB NOT NULL DEFAULT '[]', -- Array of {start: "08:00", end: "12:45"}
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Services table
CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price INTEGER NOT NULL, -- in cents
    duration_minutes INTEGER NOT NULL DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Surcharge settings table
CREATE TABLE surcharge_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barber_id UUID NOT NULL REFERENCES barbers(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('percentage', 'fixed')),
    max_value INTEGER NOT NULL DEFAULT 50, -- in cents for fixed, or percentage points for percentage
    min_value INTEGER NOT NULL DEFAULT 0,  -- in cents for fixed, or percentage points for percentage
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Customers table (needed for appointments)
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Appointments table
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barber_id UUID NOT NULL REFERENCES barbers(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES services(id) ON DELETE RESTRICT,
    appointment_date TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER NOT NULL,
    price INTEGER NOT NULL, -- in cents (base service price)
    discount INTEGER DEFAULT 0, -- in cents
    booking_fee INTEGER DEFAULT 0, -- in cents
    surcharge INTEGER DEFAULT 0, -- in cents (calculated surcharge)
    total_price INTEGER GENERATED ALWAYS AS (price - discount + booking_fee + surcharge) STORED,
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_barbers_shop_id ON barbers(shop_id);
CREATE INDEX idx_services_shop_id ON services(shop_id);
CREATE INDEX idx_surcharge_settings_barber_id ON surcharge_settings(barber_id);
CREATE INDEX idx_appointments_barber_id ON appointments(barber_id);
CREATE INDEX idx_appointments_customer_id ON appointments(customer_id);
CREATE INDEX idx_appointments_service_id ON appointments(service_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_email ON customers(email);

-- Constraints to ensure data integrity
ALTER TABLE barbers ADD CONSTRAINT check_days_valid 
    CHECK (days_on <@ ARRAY['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_shops_updated_at BEFORE UPDATE ON shops FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_barbers_updated_at BEFORE UPDATE ON barbers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_surcharge_settings_updated_at BEFORE UPDATE ON surcharge_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample data insertion
INSERT INTO shops (name, address, phone, email) VALUES 
    ('Downtown Cuts', '123 Main St, City, State', '+1-555-0123', 'info@downtowncuts.com'),
    ('Uptown Barbershop', '456 Oak Ave, City, State', '+1-555-0456', 'contact@uptownbarber.com');

INSERT INTO barbers (shop_id, name, email, phone, days_on, working_hours) VALUES 
    (
        (SELECT id FROM shops WHERE name = 'Downtown Cuts'),
        'John Smith',
        'john@downtowncuts.com',
        '+1-555-0124',
        ARRAY['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
        '[{"start": "08:00", "end": "12:45"}, {"start": "15:00", "end": "18:45"}]'::jsonb
    ),
    (
        (SELECT id FROM shops WHERE name = 'Downtown Cuts'),
        'Mike Johnson',
        'mike@downtowncuts.com',
        '+1-555-0125',
        ARRAY['tuesday', 'wednesday', 'thursday', 'friday', 'saturday'],
        '[{"start": "09:00", "end": "17:00"}]'::jsonb
    );

INSERT INTO services (shop_id, name, description, price, duration_minutes) VALUES 
    ((SELECT id FROM shops WHERE name = 'Downtown Cuts'), 'Basic Haircut', 'Standard mens haircut', 2500, 30),
    ((SELECT id FROM shops WHERE name = 'Downtown Cuts'), 'Beard Trim', 'Professional beard trimming', 1500, 15),
    ((SELECT id FROM shops WHERE name = 'Downtown Cuts'), 'Haircut + Beard', 'Complete grooming package', 3500, 45);

INSERT INTO surcharge_settings (barber_id, type, max_value, min_value) VALUES 
    ((SELECT id FROM barbers WHERE name = 'John Smith'), 'percentage', 20, 0),
    ((SELECT id FROM barbers WHERE name = 'Mike Johnson'), 'fixed', 500, 0);

INSERT INTO customers (name, email, phone) VALUES 
    ('Alice Cooper', 'alice@email.com', '+1-555-9001'),
    ('Bob Wilson', 'bob@email.com', '+1-555-9002');

-- Sample appointment
INSERT INTO appointments (barber_id, customer_id, service_id, appointment_date, duration_minutes, price, discount, booking_fee, surcharge) VALUES 
    (
        (SELECT id FROM barbers WHERE name = 'John Smith'),
        (SELECT id FROM customers WHERE name = 'Alice Cooper'),
        (SELECT id FROM services WHERE name = 'Basic Haircut'),
        '2024-03-15 10:00:00+00',
        30,
        2500,
        0,
        200,
        300
    );