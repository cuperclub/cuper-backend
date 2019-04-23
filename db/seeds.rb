# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(
  email: 'admin@example.com',
  nickname: 'admin',
  name: 'Admin User',
  password: "12345678"
)

krab = User.create(
  email: 'krabs@example.com',
  nickname: 'MrKrabs',
  name: 'Mr. Krabs',
  password: "12345678"
)

Company.create(
  ruc: '9999999999',
  economic_activity: 'Restaurant',
  business_name: 'The Krusty krab.',
  legal_representative: "Mr. Krabs",
  slogan:"Come spend your money here!",
  user_id: krab.id
)
