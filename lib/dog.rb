class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end #initialize

    
    def save
        #if id exists in database, update it, else insert and populate id
        #return instance of dog
    
        if self.id
            self.update
        else
            sql = <<-SQL
              INSERT INTO dogs (name, breed) 
              VALUES (?, ?)
            SQL
      
            DB[:conn].execute(sql, self.name, self.breed)
      
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        
        end #if
        self
    end #save

    def self.create(dog_hash)
        dog = self.new(dog_hash)
        dog.save
        dog 
    end #create

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end #update

    def self.create_table
        sql =  <<-SQL 
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
        SQL
        DB[:conn].execute(sql) 

    end #create table

    def self.drop_table
        sql =  <<-SQL 
      DROP TABLE dogs
      SQL
    DB[:conn].execute(sql) 
    end # drop table

    def self.new_from_db(row)
        id = row[0]
        name =  row[1]
        breed = row[2]
        new_dog = self.new(name: name, breed: breed, id: id)
        new_dog 
    end #new from db

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
  
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end #find by id

    def self.find_or_create_by(name: , breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?
            LIMIT 1
        SQL
  
        if row = DB[:conn].execute(sql, name, breed).first
            self.new_from_db(row)
        else
            dog_hash = {name: name, breed: breed}
            self.create(dog_hash)
        end
        
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL
  
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end #find by name

end