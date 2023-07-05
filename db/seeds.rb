# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

ApplicationRecord.transaction do
  puts "Destroying tables..."
  CatRentalRequest.destroy_all
  Cat.destroy_all
  User.destroy_all

  puts "Resetting primary keys..."
  %w(users cats cat_rental_requests).each do |table_name|
    ApplicationRecord.connection.reset_pk_sequence!(table_name)
  end

  puts "Creating users..."
  10.times do 
    User.create!(
      username: Faker::Internet.unique.username,
      password: Faker::Internet.password(min_length: 6, max_length: 12)
    )
  end

  puts "Creating cats..."
  10.times do
    Cat.create!(
      owner: User.all.sample,
      name: Faker::Creature::Cat.unique.name,
      color: %w[black white orange brown].sample,
      sex: %w[M F].sample,
      birth_date: Faker::Date.between(from: 2.years.ago, to: Date.today),
      description: Faker::Quote.most_interesting_man_in_the_world
    )
  end

  puts "Creating cat rental requests..."
  5.times do |i|
    CatRentalRequest.create!(
      cat_id: i+1,
      requester: User.all.sample,
      status: %w[APPROVED DENIED PENDING].sample,
      start_date: Faker::Date.between(from: Date.today, to: 2.days.from_now),
      end_date: Faker::Date.between(from: 3.days.from_now, to: 7.days.from_now)
    )
  end
  
  puts "Done!"
end