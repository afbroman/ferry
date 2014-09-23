require "ferry/version"
require "ferry/engine"
require "ferry/logger"
require "csv"
require 'active_record'
require 'fileutils'
require 'yaml'
require 'rails'

module Ferry


  class Export
    def to_csv()

      # ActiveRecord::Base.connection
      #ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.sqlite3') #need to automatically get db name
      #puts ActiveRecord::Base.configurations[Rails.env]['adapter']

      info = YAML::load(IO.read("config/database.yml"))     #this holds all the db config information. pretty much a rosetta stone for dbs
      db_type = info["production"]["adapter"]               #this tells us the db rails is using


      # puts Rails.configuration#.database_configuration[Rails.env]
      # puts ActiveRecord::Base.configurations[Rails.env]

      # type = db_type.downcase



      case db_type
        when "sqlite3"
          puts "its sqlite3"


          info.keys.each do |environment| 

              ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: info[environment]['database'])  #connect to sqlite3 file

              unless(Dir.exists?('db/csv'))   #creating a 'csv' folder in the 'db' folder
                Dir.mkdir('db/csv')
                puts 'db/csv created'
              end

                unless(Dir.exists?('db/csv/'+environment))    #creating folders for each file (dev, test, prod, etc)
                  Dir.mkdir('db/csv/'+environment)
                  puts 'db/csv/'+environment+' created'
                end

                      ActiveRecord::Base.connection.tables.each do |model|                                #for each model in the db
                        everything = ActiveRecord::Base.connection.execute('SELECT * FROM '+model+';')    #get all the records

                        if everything[0].nil?   #do not create a csv for an empty table
                          next
                        end

                        CSV.open("db/csv/"+environment+"/"+model+".csv", "w") do |csv|    #create a csv for each table, titled 'model.csv'

                          size = everything[0].length / 2
                          keys = everything[0].keys.first(size)

                          csv << keys     #first row contains column names
                          
                          everything.each do |row|
                            csv << row.values_at(*keys)     #subsequent rows hold record values
                          end
                        end
                      end

          end


        when "mysql"
          puts "its mysql"
        when "postgres"
          puts "its postgres"
        else
          puts "unknown db type"
      end
          
            
      puts Time.now()

    end
  end

  # class ActiveRecord::Relation
    # def migrate(options, &block)
    #   options[:max_workers] ||= 4
    #   options[:batch_size]  ||= 10_000

    #   log = Logger.new()

    #   active_workers = []
    #   collection = self
    #   collection.find_in_batches(batch_size: options[:batch_size]) do |batch|
    #     if active_workers.length >= options[:max_workers]
    #       log.write "active_workers oversized at capacity of #{active_workers.length}/#{options[:max_workers]}"
    #       finished_process = Process.wait
    #       log.write "finished_process: #{finished_process}"
    #       active_workers.delete finished_process
    #       log.write "active_workers capacity now at: #{active_workers.length}/#{options[:max_workers]}"
    #     else
    #       active_workers << fork do
    #         ActiveRecord::Base.connection.reconnect!
    #         log.write "kicking off engine on batch(#{batch.first}-#{batch.last})"
    #         engine = Engine.new()
    #         engine.run({log: log, batch: batch}, &block)
    #       end
    #     end
    #     ActiveRecord::Base.connection.reconnect!
    #   end
    # end
  # end
end
