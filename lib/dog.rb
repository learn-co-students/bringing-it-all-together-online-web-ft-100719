class Dog

    attr_accessor :name, :breed, :id
   

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
        

    end

    def self.create_table

        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL

        DB[:conn].execute(sql)

    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
         
        sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self

    end

    def self.create(attributes)
        
        new_dog = Dog.new(attributes)
        
        new_dog.save

    end

    def self.new_from_db(arr)
        new_dog = Dog.new(id: arr[0], name: arr[1], breed: arr[2])
    end

    def self.find_by_id(x)

        sql = <<-SQL
        SELECT * FROM dogs  
        WHERE id = ?
        SQL

        new_dog = DB[:conn].execute(sql, x)[0]
        new_dog1 = Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])


    end

    

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        
        if !dog.empty?
            
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
            
        else
            
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs  
        WHERE name = ?
        SQL

        new_dog = DB[:conn].execute(sql, name)[0]
        new_dog1 = Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])

    end

    def update
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]


    end



    











end