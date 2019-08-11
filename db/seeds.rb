# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(
  email: 'client@example.com',
  nickname: 'client',
  name: 'Client User',
  password: "12345678",
  national_id: '1234567893'
)

if Category.count == 0
  [
    "Comida",
    "Medicina",
    "Electrodomesticos",
    "Servicios profesionales",
    "Floristeria"
  ].each do |category_name|
    Category.where(
      name: category_name,
      points_per_dollar: 1
    ).first_or_create
  end
end

partner = User.create(
  email: 'partner@example.com',
  nickname: 'partner',
  name: 'Partner',
  password: "12345678",
  national_id: '1234567891'
)

cashier = User.create(
  email: 'cashier@example.com',
  nickname: 'chasier',
  name: 'Chasier',
  password: "12345678",
  national_id: '1234567892'
)


company = Company.create(
  ruc: '9999999999',
  economic_activity: 'Restaurant',
  business_name: 'The Krusty krab.',
  legal_representative: "Mr. Krabs",
  slogan:"Come spend your money here!",
  category: Category.first,
)

office = Office.create(
  name: 'Sucursal 1',
  email:'sucursal_1@example.com',
  address:'24 de Mayo',
  company: company,
)

Promotion.create(
  title: 'Hamburguesas 2x1',
  description: 'Aprovecha esta mega oferta',
  terms: 'Valido los días Lunes',
  total_rewards: 10,
  points_required: 100,
  start_at: Time.now,
  end_at: Time.now + 72*60*60, #valido x 3 dias
  office: office,
)

Employee.create(
  user: cashier,
  company: company,
  role: 'cashier',
  status: 'approved'
)

Employee.create(
  user: partner,
  company: company,
  role: 'partner',
  status: 'approved'
)

####Administration Cuper######

cuper_employee = User.create(
  email: 'admin@example.com',
  nickname: 'admin',
  name: 'Admin User',
  password: "12345678",
  national_id: '1234567890',
  is_admin: true
)

cuper_company = Company.create(
  ruc: '9999999990',
  economic_activity: 'Comercial',
  business_name: 'Cuper Club',
  legal_representative: "Anyone",
  slogan:"Fideliza yours Customers",
  category: Category.first,
)

cuper_employee = Employee.create(
  user: cuper_employee,
  company: cuper_company,
  role: 'partner',
  status: 'approved'
)

free_plan = Plan.create(
  name: 'Freemiun',
  price: 0,
  information: 'Try 90 days free',
  days: 90
)

AppSetting.create(
  plan_selected_id: free_plan.id,
  points_by_register: 10,
  main_employee_id: cuper_employee.id
)
