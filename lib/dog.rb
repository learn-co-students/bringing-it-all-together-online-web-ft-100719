class Dog

  attr_accessor :name, :breed, :id

  def initialize(args)
    @name = args[:name]
    @breed = args[:breed]
    @id = args[:id]
  end

  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT 
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs
        (name, breed)
        VALUES
        (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    end
    self
  end

  def self.create(args)
    dog = self.new(args)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(args)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    attributes = DB[:conn].execute(sql, args[:name], args[:breed])
    if attributes.empty?
      dog = self.create(args)
    else
      dog = self.new_from_db(attributes[0])
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end