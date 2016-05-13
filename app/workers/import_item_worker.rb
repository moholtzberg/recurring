class ImportItemWorker
  include Sidekiq::Worker

  def perform(file_path)
  	puts "**********Start Importing the items*********"
  	import_hisotry = ImportHistory.create(nb_imported: 0, nb_failed:0, nb_in_queue: 0)
  	item_import = ItemImport.new
  	item_import.put_file_path(file_path)
  	item_import.put_import_hisotry(import_hisotry)
  	item_import.save	
  	puts "**********End of Importing the items*********"
  end
end