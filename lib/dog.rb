require 'pry'
class Dog

  attr_accessor :name, :breed, :id

  def initialize(hash)
    @id=(hash[:id]=nil)
    @name=hash[:name]
    @breed=hash[:breed]
  end

  def self.create_table
    sql= <<-SQL
    CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql="DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    dog_hash={id:row[0], name:row[1], breed:row[2]}
    dog=Dog.new(dog_hash)
    dog

  end

















end
