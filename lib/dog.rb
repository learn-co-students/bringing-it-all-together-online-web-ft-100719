class Dog

attr_accessor :name, :breed
attr_reader :id

    def initialize(id:nil, name:, breed:)
        @id=id
        @name=name
        @breed=breed
    end

    def self.create_table
        sql= <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql= <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        # binding.pry
        if self.id
            self.update
        else
            sql= <<-SQL
            INSERT INTO dogs (name,breed)
            VALUES (?,?)
            SQL
            DB[:conn].execute(sql,self.name,self.breed)
            # binding.pry
            @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def self.create(name:,breed:)
        new_dog=Dog.new(name:name, breed:breed)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        dog=Dog.new(id:row[0],name:row[1],breed:row[2])
    end

    def self.find_by_id(id)
        sql= <<-SQL
        SELECT * FROM dogs
        WHERE id=?
        LIMIT 1
        SQL
        DB[:conn].execute(sql,id).map do |dog|
            self.new_from_db(dog)
        end.first
    end

    def self.find_or_create_by(info)
        
        sql=<<-SQL
        SELECT * FROM dogs
        WHERE name=? AND breed=?
        SQL
        
        if DB[:conn].execute(sql,info[:name],info[:breed])[0]
            # binding.pry
            row=DB[:conn].execute(sql,info[:name],info[:breed])[0]
            self.find_by_id(row[0])
        else
            self.create(name:info[:name],breed:info[:breed])
        end
    end

    def self.find_by_name(dog_name)
        sql= <<-SQL
        SELECT * FROM dogs
        WHERE name=?
        LIMIT 1
        SQL
        DB[:conn].execute(sql,dog_name).map do |dog|
            self.new_from_db(dog)
        end.first
    end

    def update
        sql= <<-SQL
        UPDATE dogs
        SET name=?, breed=?
        WHERE id=?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    

end