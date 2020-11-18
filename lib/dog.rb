require 'pry'

class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs( id INTEGER PRIMARY KEY, name TEXT, BREED TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
        self
    end

    def self.create(hash)
        new(hash).tap{|dog| dog.save}
    end

    def self.new_from_db(row)
        new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_by_id(id)
        new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first)
    end

    def self.find_or_create_by(hash)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE (name, breed) = (?, ?)", hash[:name], hash[:breed]).first
        row ? new_from_db(row) : create(hash)
    end

    def self.find_by_name(name)
        new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first)
    end

    def update
        id ? DB[:conn].execute("UPDATE dogs SET (name, breed) = (?, ?) WHERE id = ? ", name, breed, id) : save
    end
end
