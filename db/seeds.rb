# Make some dummy people

Person.create(
  first_name: "Jim",
  last_name: "Tester",
  email_address: "jim@example.com",
  address_1: "123 N Michigan Ave",
  city: "Chicago",
  state: "IL",
  postal_code: "60601",
  geography_id: "42", # ward
  primary_device_id: 1,
  primary_device_description: "Apple Macbook Pro",
  secondary_device_id: 2,
  secondary_device_description: "Samsung Galaxy",
  primary_connection_id: 1,
  phone_number: "312-555-9090",
  participation_type: "in-person"
)

Person.create(
  first_name: "Jane",
  last_name: "Developer",
  email_address: "jane@example.com",
  address_1: "1060 W Addison",
  city: "Chicago",
  state: "IL",
  postal_code: "60613",
  geography_id: "44", # ward
  primary_device_id: 1,
  primary_device_description: "iPad",
  secondary_device_id: 2,
  secondary_device_description: "Apple laptop",
  primary_connection_id: 1,
  phone_number: "312-555-8888",
  participation_type: "remote"
)

User.create(
  email: 'cutgroup@example.com',
  password:'foobar123',
  password_confirmation:'foobar123',
  approved: true
)