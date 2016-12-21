# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

[
  {name: "Adam", avatar: "avatar1.jpg"},
  {name: "Wendy", avatar: "avatar2.jpg"},
  {name: "Vcool", avatar: "avatar3.jpg"},
  {name: "Christian", avatar: "avatar4.jpg"},
  {name: "Barock", avatar: "avatar5.jpg"},
  {name: "Yoseph", avatar: "avatar6.jpg"}
].each do |user|
  user = User.new(
    name: user[:name],
    avatar: user[:avatar]
  )
  user.save!
end

[
  ["Hello world", 1],
  ["Ayo ntar main FIFA oi!", 4],
  ["Ah lu kalah mulu, bosen gue", 2],
  ["Sad truth :(", 5],
  ["Nih gue jual stick PS, 50.000", 6],
  ["Biar lu menang kris, hahahaha", 3]
].each do |chat|
  text = chat[0]
  user_id = chat[1]

  chat = Chat.new(
    sender_id: user_id,
    text: text
  )

  chat.save!
end
