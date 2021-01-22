# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
iosxr = Driver.new(name: 'iosxr')
iosxr.template = <<~EOL
prompt(/#/)
login do |*args|
  username, password = *args
  waitfor(/Username: /) && puts(username)
  waitfor(/Password: /) && puts(password)
  waitfor

  cmd('terminal length 0')
  cmd('terminal width 0')
end
EOL

iosxr.save!
