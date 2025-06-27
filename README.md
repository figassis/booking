# Barber Booking SaaS Architecture

## Overview

This document describes the architecture for a barber booking Software-as-a-Service (SaaS) platform. The system enables barbershops to manage their services, barbers, and appointments while allowing customers to book appointments online.

## System Architecture

### Technology Stack
- **Database**: PostgreSQL with JSONB support
- **Primary Keys**: UUIDs (UUID v4) for all entities
- **Monetary Values**: Stored as integers in cents
- **Timestamps**: ISO 8601 format with timezone support

## Data Models

### Core Entities

#### 1. Shops
Represents barbershops in the system.

```sql
shops {
  id: UUID (Primary Key)
  name: VARCHAR(255) - Shop name
  address: TEXT - Physical address
  phone: VARCHAR(20) - Contact phone
  email: VARCHAR(255) - Contact email
  timezone: VARCHAR(50) - Shop timezone (default: UTC)
  created_at: TIMESTAMP WITH TIME ZONE
  updated_at: TIMESTAMP WITH TIME ZONE
}
```

**Business Rules:**
- Each shop operates independently
- Shops can have multiple barbers and services
- Timezone is crucial for appointment scheduling

#### 2. Barbers
Individual barbers working at shops.

```sql
barbers {
  id: UUID (Primary Key)
  shop_id: UUID (Foreign Key -> shops.id)
  name: VARCHAR(255) - Barber name
  email: VARCHAR(255) - Contact email
  phone: VARCHAR(20) - Contact phone
  days_on: TEXT[] - Working days array
  working_hours: JSONB - Daily schedule
  is_active: BOOLEAN - Active status
  created_at: TIMESTAMP WITH TIME ZONE
  updated_at: TIMESTAMP WITH TIME ZONE
}
```

**Working Days Format:**
```javascript
["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
```

**Working Hours Format:**
```json
[
  {"start": "08:00", "end": "12:45"},
  {"start": "15:00", "end": "18:45"}
]
```

**Business Rules:**
- Barbers belong to one shop
- Can work multiple time slots per day
- Working hours stored in 24-hour format
- Days are stored as lowercase strings

#### 3. Services
Services offered by barbershops.

```sql
services {
  id: UUID (Primary Key)
  shop_id: UUID (Foreign Key -> shops.id)
  name: VARCHAR(255) - Service name
  description: TEXT - Service description
  price: INTEGER - Base price in cents
  duration_minutes: INTEGER - Service duration
  is_active: BOOLEAN - Active status
  created_at: TIMESTAMP WITH TIME ZONE
  updated_at: TIMESTAMP WITH TIME ZONE
}
```

**Business Rules:**
- Services belong to shops
- Price stored in cents (e.g., $25.00 = 2500)
- Duration used for scheduling conflicts

#### 4. Surcharge Settings
Configurable surcharges per barber.

```sql
surcharge_settings {
  id: UUID (Primary Key)
  barber_id: UUID (Foreign Key -> barbers.id)
  type: VARCHAR(20) - "percentage" or "fixed"
  max_value: INTEGER - Maximum surcharge
  min_value: INTEGER - Minimum surcharge
  is_active: BOOLEAN - Active status
  created_at: TIMESTAMP WITH TIME ZONE
  updated_at: TIMESTAMP WITH TIME ZONE
}
```

**Business Rules:**
- Each barber can have custom surcharge settings
- Percentage type: values are percentage points (20 = 20%)
- Fixed type: values are in cents
- Used for peak hours, special services, etc.

#### 5. Customers
End users who book appointments.

```sql
customers {
  id: UUID (Primary Key)
  name: VARCHAR(255) - Customer name
  email: VARCHAR(255) - Contact email
  phone: VARCHAR(20) - Contact phone (required)
  created_at: TIMESTAMP WITH TIME ZONE
  updated_at: TIMESTAMP WITH TIME ZONE
}
```

**Business Rules:**
- Phone number is required for booking
- Email is optional but recommended
- Customers can book with multiple shops

#### 6. Appointments
Scheduled appointments between customers and barbers.

```sql
appointments {
  id: UUID (Primary Key)
  barber_id: UUID (Foreign Key -> barbers.id)
  customer_id: UUID (Foreign Key -> customers.id)
  service_id: UUID (Foreign Key -> services.id)
  appointment_date: TIMESTAMP WITH TIME ZONE
  duration_minutes: INTEGER - Actual duration
  price: INTEGER - Base service price in cents
  discount: INTEGER - Discount amount in cents
  booking_fee: INTEGER - Platform fee in cents
  surcharge: INTEGER - Additional charges in cents
  total_price: INTEGER - Computed total (price - discount + booking_fee + surcharge)
  status: VARCHAR(20) - Appointment status
  notes: TEXT - Additional notes
  created_at: TIMESTAMP WITH TIME ZONE
  updated_at: TIMESTAMP WITH TIME ZONE
}
```

**Appointment Status Values:**
- `scheduled` - Initially booked
- `confirmed` - Confirmed by barber/shop
- `in_progress` - Currently happening
- `completed` - Finished successfully
- `cancelled` - Cancelled by customer/barber
- `no_show` - Customer didn't show up

**Pricing Calculation:**
```
total_price = price - discount + booking_fee + surcharge
```

## Relationships

### Entity Relationship Diagram
```
shops (1) --> (many) barbers
shops (1) --> (many) services
barbers (1) --> (many) surcharge_settings
barbers (1) --> (many) appointments
customers (1) --> (many) appointments
services (1) --> (many) appointments
```

### Key Relationships
1. **Shop → Barbers**: One-to-many (CASCADE DELETE)
2. **Shop → Services**: One-to-many (CASCADE DELETE)
3. **Barber → Surcharge Settings**: One-to-many (CASCADE DELETE)
4. **Barber → Appointments**: One-to-many (CASCADE DELETE)
5. **Customer → Appointments**: One-to-many (CASCADE DELETE)
6. **Service → Appointments**: One-to-many (RESTRICT DELETE)

## Data Integrity Constraints

### Referential Integrity
- All foreign keys use CASCADE DELETE except services (RESTRICT)
- Services use RESTRICT to prevent accidental deletion of referenced services

### Check Constraints
- `surcharge_settings.type` must be 'percentage' or 'fixed'
- `appointments.status` must be valid status value
- `barbers.days_on` must contain valid day names

### Indexes
Performance-critical indexes:
- `barbers(shop_id)`
- `appointments(barber_id, appointment_date)`
- `appointments(customer_id)`
- `customers(phone, email)`

## Business Logic Rules

### Scheduling Rules
1. **Availability Check**: Appointments must fall within barber's working hours and days
2. **Conflict Prevention**: No overlapping appointments for same barber
3. **Duration Validation**: Appointment duration must fit within available time slots

### Pricing Rules
1. **Base Price**: From service.price
2. **Surcharge Calculation**: Applied based on barber's surcharge_settings
3. **Discount Application**: Subtracted from base price
4. **Booking Fee**: Platform fee added to total
5. **Final Total**: Computed automatically via database trigger

### Data Validation Rules
1. **Time Format**: All times in 24-hour format (HH:MM)
2. **Date Format**: ISO 8601 with timezone
3. **Phone Format**: E.164 format recommended
4. **Price Values**: Always positive integers in cents

## Extensibility Considerations

### Future Enhancements
- **Multi-location Shops**: Add shop_locations table
- **Barber Specializations**: Add barber_services junction table
- **Recurring Appointments**: Add recurrence patterns
- **Payment Integration**: Add payment_transactions table
- **Reviews/Ratings**: Add customer_reviews table
- **Inventory Management**: Add products/inventory tables

### Scalability Patterns
- **Horizontal Scaling**: Shop-based partitioning
- **Caching Strategy**: Cache barber availability, popular services
- **Search Optimization**: Full-text search on shop/barber names
- **Time Zone Handling**: Convert all times to UTC for storage

## API Design Patterns

### RESTful Endpoints Structure
```
/api/v1/shops/{shopId}/barbers
/api/v1/shops/{shopId}/services
/api/v1/barbers/{barberId}/appointments
/api/v1/customers/{customerId}/appointments
```

### Common Query Patterns
1. **Availability Queries**: Find available barbers for specific date/time
2. **Schedule Queries**: Get barber's daily/weekly schedule
3. **Pricing Queries**: Calculate total price including surcharges
4. **Booking Queries**: Create appointments with conflict checking

## Security Considerations

### Data Protection
- Customer PII (phone, email) requires encryption at rest
- Appointment data contains sensitive scheduling information
- Shop/barber data may include business-sensitive information

### Access Control
- Shop owners can only access their shop's data
- Barbers can only access their appointments
- Customers can only access their own appointments

This architecture provides a solid foundation for a barber booking SaaS platform with room for future enhancements and scalability needs.