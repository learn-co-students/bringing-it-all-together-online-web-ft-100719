require 'pry'
class Dog

  attr_accessor :name, :breed, :id

  def initialize(hash, id=nil)
    @id=hash[:id]
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

  def save
    sql= <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
   dog = Dog.new(hash)
   dog.save
   dog
  end



  def self.new_from_db(row)
    dog_hash={id:row[0], name:row[1], breed:row[2]}
    dog=Dog.new(dog_hash)
    dog
  end

  def self.find_by_id(id)
    sql= <<-SQL
    SELECT * FROM dogs WHERE id = ?

    SQL
    dog= DB[:conn].execute(sql,id)[0]
    dog_hash={id:dog[0], name:dog[1], breed:dog[2]}
    new_dog=Dog.new(dog_hash)
    new_dog
  end

  def self.find_or_create_by(name:, breed:)
    row=DB[:conn].execute("SELECT * FROM dogs WHERE name =? AND breed = ?", name, breed)

    if !row.empty?
      dog_d=row[0]
      dog_hash={id:dog_d[0], name:dog_d[1], breed:dog_d[2]}
      dog=Dog.new(dog_hash)
    else
      dog=self.create(name:name, breed:breed)
    end
  dog

  end

  def self.find_by_name(name)
    sql= "SELECT * FROM dogs WHERE name = ?"
    dog= DB[:conn].execute(sql,name)[0]
    dog_hash={id:dog[0], name:dog[1], breed:dog[2]}
    new_dog=Dog.new(dog_hash)
    new_dog
  end

  def update
    sql="UPDATE dogs SET name =?, breed=? WHERE id = ?"
    DB[:conn].execute(sql,self.name, self.breed, self.id)
  end

















end
