DROP TABLE IF EXISTS "public"."shops";
-- Table Definition
CREATE TABLE "public"."shops" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "name" varchar(255) NOT NULL,
    "address" text,
    "phone" varchar(20),
    "email" varchar(255),
    "timezone" varchar(50) DEFAULT 'UTC'::character varying,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "public"."services";
-- Table Definition
CREATE TABLE "public"."services" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "shop_id" uuid NOT NULL,
    "name" varchar(255) NOT NULL,
    "description" text,
    "price" int4 NOT NULL,
    "duration_minutes" int4 NOT NULL DEFAULT 30,
    "is_active" bool DEFAULT true,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "public"."surcharge_settings";
-- Table Definition
CREATE TABLE "public"."surcharge_settings" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "barber_id" uuid NOT NULL,
    "type" varchar(20) NOT NULL CHECK ((type)::text = ANY ((ARRAY['percentage'::character varying, 'fixed'::character varying])::text[])),
    "max_value" int4 NOT NULL DEFAULT 50,
    "min_value" int4 NOT NULL DEFAULT 0,
    "is_active" bool DEFAULT true,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "public"."barbers";
-- Table Definition
CREATE TABLE "public"."barbers" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "shop_id" uuid NOT NULL,
    "name" varchar(255) NOT NULL,
    "email" varchar(255),
    "phone" varchar(20),
    "days_on" _text NOT NULL DEFAULT '{}'::text[] CHECK (days_on <@ ARRAY['monday'::text, 'tuesday'::text, 'wednesday'::text, 'thursday'::text, 'friday'::text, 'saturday'::text, 'sunday'::text]),
    "working_hours" jsonb NOT NULL DEFAULT '[]'::jsonb,
    "is_active" bool DEFAULT true,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "public"."appointments";
-- Table Definition
CREATE TABLE "public"."appointments" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "barber_id" uuid NOT NULL,
    "customer_id" uuid NOT NULL,
    "service_id" uuid NOT NULL,
    "appointment_date" timestamptz NOT NULL,
    "duration_minutes" int4 NOT NULL,
    "price" int4 NOT NULL,
    "discount" int4 DEFAULT 0,
    "booking_fee" int4 DEFAULT 0,
    "surcharge" int4 DEFAULT 0,
    "total_price" int4,
    "status" varchar(20) DEFAULT 'scheduled'::character varying CHECK ((status)::text = ANY ((ARRAY['scheduled'::character varying, 'confirmed'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'cancelled'::character varying, 'no_show'::character varying])::text[])),
    "notes" text,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "public"."customers";
-- Table Definition
CREATE TABLE "public"."customers" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "name" varchar(255) NOT NULL,
    "email" varchar(255),
    "phone" varchar(20) NOT NULL,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

INSERT INTO "public"."shops" ("id", "name", "address", "phone", "email", "timezone", "created_at", "updated_at") VALUES
('1a2fd192-5074-42d5-91dc-398c95a62936', 'New shop 3', 'Some other address', '+1-555-0123', 'info@downtowncuts.com', 'UTC', '2025-06-27 15:33:33.219112+00', '2025-06-27 16:34:38.409192+00'),
('5bd6b4c3-d7bc-4125-b4c1-2face3fbe17f', 'Downtown Cuts', '123 Main St, City, State', '+1-555-0123', 'info@downtowncuts.com', 'UTC', '2025-06-27 12:21:07.364536+00', '2025-06-27 12:21:07.364536+00'),
('77cb3871-17c0-4923-974d-1934ab14f5bb', 'Uptown Barbershop', '456 Oak Ave, City, State', '+1-555-0456', 'contact@uptownbarber.com', 'UTC', '2025-06-27 12:21:07.364536+00', '2025-06-27 12:21:07.364536+00');

INSERT INTO "public"."services" ("id", "shop_id", "name", "description", "price", "duration_minutes", "is_active", "created_at", "updated_at") VALUES
('4df9480f-28e6-4f8d-a073-6a5e434d0140', '5bd6b4c3-d7bc-4125-b4c1-2face3fbe17f', 'Beard Trim', 'Professional beard trimming', 1500, 15, 't', '2025-06-27 12:21:07.364892+00', '2025-06-27 12:21:07.364892+00'),
('6aecae6a-afd6-482e-bbfd-124196a26d4b', '5bd6b4c3-d7bc-4125-b4c1-2face3fbe17f', 'Basic Haircut for kids', 'Standard mens haircut', 2500, 30, 't', '2025-06-27 15:41:21.805749+00', '2025-06-27 15:41:21.805756+00'),
('9d70539d-ec3a-437f-a958-10be8802b22b', '5bd6b4c3-d7bc-4125-b4c1-2face3fbe17f', 'Basic Haircut', 'Standard mens haircut', 2000, 30, 't', '2025-06-27 12:21:07.364892+00', '2025-06-27 16:40:54.319697+00'),
('f225036c-fe79-48dc-bde2-d6cb441b4df9', '5bd6b4c3-d7bc-4125-b4c1-2face3fbe17f', 'Haircut + Beard', 'Complete grooming package', 3500, 45, 't', '2025-06-27 12:21:07.364892+00', '2025-06-27 12:21:07.364892+00');

INSERT INTO "public"."surcharge_settings" ("id", "barber_id", "type", "max_value", "min_value", "is_active", "created_at", "updated_at") VALUES
('213c80a7-3b74-4365-836d-6f2a51872fcc', '0669a72d-11ca-4f1b-8ecf-ea02c88a8d39', 'percentage', 20, 0, 't', '2025-06-27 12:21:07.365032+00', '2025-06-27 12:21:07.365032+00'),
('829d1721-81a7-47c4-b541-a081d6a2ed3d', '22e59315-06f0-40e7-9760-14a7120ada6e', 'fixed', 500, 0, 't', '2025-06-27 12:21:07.365032+00', '2025-06-27 12:21:07.365032+00');

INSERT INTO "public"."barbers" ("id", "shop_id", "name", "email", "phone", "days_on", "working_hours", "is_active", "created_at", "updated_at") VALUES
('0669a72d-11ca-4f1b-8ecf-ea02c88a8d39', '5bd6b4c3-d7bc-4125-b4c1-2face3fbe17f', 'Jane Smith', 'john@downtowncuts.com', '+1-555-0124', '{monday,tuesday,wednesday,thursday,friday}', '[{"end": "12:45", "start": "08:00"}, {"end": "18:45", "start": "15:00"}]', 't', '2025-06-27 12:21:07.364632+00', '2025-06-27 16:36:40.118776+00'),
('22e59315-06f0-40e7-9760-14a7120ada6e', '5bd6b4c3-d7bc-4125-b4c1-2face3fbe17f', 'Mike Johnson', 'mike@downtowncuts.com', '+1-555-0125', '{tuesday,wednesday,thursday,friday,saturday}', '[{"end": "17:00", "start": "09:00"}]', 't', '2025-06-27 12:21:07.364632+00', '2025-06-27 12:21:07.364632+00'),
('85c1e390-df66-4683-8204-746d133483ac', '5bd6b4c3-d7bc-4125-b4c1-2face3fbe17f', 'Jane Smith the second', 'john@downtowncuts.com', '+1-555-0124', '{monday,tuesday,wednesday,thursday,friday}', '[{"end": "12:45", "start": "08:00"}, {"end": "18:45", "start": "15:00"}]', 't', '2025-06-27 15:39:47.258854+00', '2025-06-27 15:39:47.258859+00');

INSERT INTO "public"."appointments" ("id", "barber_id", "customer_id", "service_id", "appointment_date", "duration_minutes", "price", "discount", "booking_fee", "surcharge", "total_price", "status", "notes", "created_at", "updated_at") VALUES
('2ee48021-5e2a-45a4-ae3f-04fc47eced9b', '0669a72d-11ca-4f1b-8ecf-ea02c88a8d39', '4117463b-cc62-4574-bc86-60dc3a6895c6', '9d70539d-ec3a-437f-a958-10be8802b22b', '2024-03-17 10:00:00+00', 30, 2500, 0, 200, 300, 3000, 'scheduled', NULL, '2025-07-11 12:28:31.78937+00', '2025-07-11 12:28:31.789374+00'),
('37f5bbe0-cd00-4505-a198-5d4edda38faa', '0669a72d-11ca-4f1b-8ecf-ea02c88a8d39', '4117463b-cc62-4574-bc86-60dc3a6895c6', '9d70539d-ec3a-437f-a958-10be8802b22b', '2024-03-19 10:00:00+00', 30, 2500, 0, 200, 300, 3000, 'scheduled', NULL, '2025-07-11 12:28:40.298142+00', '2025-07-11 12:28:40.298149+00'),
('7467fcc5-b732-43f2-8668-a23f9d159b8e', '0669a72d-11ca-4f1b-8ecf-ea02c88a8d39', '4117463b-cc62-4574-bc86-60dc3a6895c6', '9d70539d-ec3a-437f-a958-10be8802b22b', '2024-03-16 10:00:00+00', 30, 2500, 0, 200, 300, 3000, 'scheduled', NULL, '2025-07-11 12:28:27.114576+00', '2025-07-11 12:28:27.11459+00'),
('af0a9f71-0e04-4bfb-a978-bae6e58d1ba2', '0669a72d-11ca-4f1b-8ecf-ea02c88a8d39', '4117463b-cc62-4574-bc86-60dc3a6895c6', '9d70539d-ec3a-437f-a958-10be8802b22b', '2024-03-15 10:00:00+00', 30, 2500, 0, 200, 300, 3000, 'confirmed', NULL, '2025-06-27 12:21:07.365248+00', '2025-06-27 16:44:16.567143+00'),
('c63c9bcb-692f-43e8-80da-4b79a216e05c', '0669a72d-11ca-4f1b-8ecf-ea02c88a8d39', '4117463b-cc62-4574-bc86-60dc3a6895c6', '9d70539d-ec3a-437f-a958-10be8802b22b', '2024-03-15 10:00:00+00', 30, 2500, 0, 200, 300, 3000, 'scheduled', NULL, '2025-06-27 15:51:10.644453+00', '2025-06-27 15:51:10.644459+00'),
('e5123bb1-5a2a-4bee-9632-5cdaf74a3714', '0669a72d-11ca-4f1b-8ecf-ea02c88a8d39', '4117463b-cc62-4574-bc86-60dc3a6895c6', '9d70539d-ec3a-437f-a958-10be8802b22b', '2024-03-18 10:00:00+00', 30, 2500, 0, 200, 300, 3000, 'scheduled', NULL, '2025-07-11 12:28:35.619581+00', '2025-07-11 12:28:35.61959+00'),
('ef8976b9-16c7-4d6b-8b2f-9b236479f2bb', '0669a72d-11ca-4f1b-8ecf-ea02c88a8d39', '4117463b-cc62-4574-bc86-60dc3a6895c6', '9d70539d-ec3a-437f-a958-10be8802b22b', '2024-03-15 10:00:00+00', 30, 2500, 0, 200, 300, 3000, 'scheduled', NULL, '2025-06-27 15:50:29.881193+00', '2025-06-27 15:50:29.881199+00');

INSERT INTO "public"."customers" ("id", "name", "email", "phone", "created_at", "updated_at") VALUES
('32f42128-b84d-4176-87ca-2d6401a5a4ca', 'Bob Wilson', 'bob@email.com', '+1-555-9002', '2025-06-27 12:21:07.365158+00', '2025-06-27 12:21:07.365158+00'),
('4117463b-cc62-4574-bc86-60dc3a6895c6', 'Alice Cooper', 'alice@email.com', '+1-555-9001', '2025-06-27 12:21:07.365158+00', '2025-06-27 12:21:07.365158+00');

ALTER TABLE "public"."services" ADD FOREIGN KEY ("shop_id") REFERENCES "public"."shops"("id") ON DELETE CASCADE;


-- Indices
CREATE INDEX idx_services_shop_id ON public.services USING btree (shop_id);
ALTER TABLE "public"."surcharge_settings" ADD FOREIGN KEY ("barber_id") REFERENCES "public"."barbers"("id") ON DELETE CASCADE;


-- Indices
CREATE INDEX idx_surcharge_settings_barber_id ON public.surcharge_settings USING btree (barber_id);
ALTER TABLE "public"."barbers" ADD FOREIGN KEY ("shop_id") REFERENCES "public"."shops"("id") ON DELETE CASCADE;


-- Indices
CREATE INDEX idx_barbers_shop_id ON public.barbers USING btree (shop_id);
ALTER TABLE "public"."appointments" ADD FOREIGN KEY ("service_id") REFERENCES "public"."services"("id") ON DELETE RESTRICT;
ALTER TABLE "public"."appointments" ADD FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id") ON DELETE CASCADE;
ALTER TABLE "public"."appointments" ADD FOREIGN KEY ("barber_id") REFERENCES "public"."barbers"("id") ON DELETE CASCADE;


-- Indices
CREATE INDEX idx_appointments_barber_id ON public.appointments USING btree (barber_id);
CREATE INDEX idx_appointments_customer_id ON public.appointments USING btree (customer_id);
CREATE INDEX idx_appointments_service_id ON public.appointments USING btree (service_id);
CREATE INDEX idx_appointments_date ON public.appointments USING btree (appointment_date);
CREATE INDEX idx_appointments_status ON public.appointments USING btree (status);


-- Indices
CREATE INDEX idx_customers_phone ON public.customers USING btree (phone);
CREATE INDEX idx_customers_email ON public.customers USING btree (email);
