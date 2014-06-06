#   -----------------------------------------------------------------------------------------
#   -----------------------------------------------------------------------------------------
#                                   Media Collection Framwork                                    
#   -----------------------------------------------------------------------------------------
#   -----------------------------------------------------------------------------------------

#
#

#   This builds the API to the Media Collection Framework
#   It will allow for quick browsing/searching/updating of content

#
#

#   -----------------------------------------------------------------------------------------
#                                         config   
#
#   Current issues: 
# => Trouble connecting to collections                                  
#   -----------------------------------------------------------------------------------------

require 'rubygems'
require 'sinatra'
require 'json/ext' # required for .to_json
require 'uri'

require 'mongo'
include Mongo

configure do
  conn = MongoClient.new("um.media.mit.edu", 27017)
  set :mongo_connection, conn
  set :mongo_db, conn.db('mcf')
  #auth = db.authenticate(my_user_name, my_password)

end


#   -----------------------------------------------------------------------------------------
#                                     models: deprecated   
#
#   Current issues: 
# => Needs to include content objects.
# => ROs need to eventually include embeded docs for twitter etc?
#   -----------------------------------------------------------------------------------------

# class Renderobjects
#   include MongoMapper::Document

#   urlRegex = /\A(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?\z/
  
#   #required keys
#   timestamps!
#   key :title, String, :required => true
#   key :url, String, :required => true, :format => urlRegex
#   key :render_type, String, :required => true
  
#   #optional keys
#   key :published_at, Time
#   key :thumb, String, :format => urlRegex
#   key :creator, String
#   key :meta, Hash

# end



#   -----------------------------------------------------------------------------------------
#                                       static pages 
#   Current issues:
# => Need to style and add documentation.  
#   -----------------------------------------------------------------------------------------

get '/' do
  erb :index
end



#   -----------------------------------------------------------------------------------------
#                                   routes for testing/dev 
#   -----------------------------------------------------------------------------------------

#this lists all collections
get '/collections/?' do
  content_type :json
  settings.mongo_db.collection_names.to_json
end

#test the data that you're about to enter into a new document
#example: http://localhost:9393/Renderobjects/new/test/?title=thing&url=http://stackoverflow.com/questions/1805761/check-if-url-is-valid-ruby&render_type=test
# get '/Renderobjects/new/test/?' do
# 	# content_type :json
# 	response = " "
# 	response += "You need to provide a URL. " unless params[:url]
# 	response += "Your url is fucked up. " if params[:url] && !(/\A(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?\z/ =~ params[:url])
# 	response += "You need to provide a title. " unless params[:title]
# 	response += "You need to provide a render_type. " unless params[:render_type]
# 	response === " " ? params.to_json : response
# end



#   -----------------------------------------------------------------------------------------
#                                       get methods 
#   -----------------------------------------------------------------------------------------

#this lists all documents in render objects
get '/Renderobjects/?' do
  content_type :json
  settings.mongo_db['Renderobjects'].find.to_a.to_json
end

# find a document by its ID
get '/Renderobjects/id/:id/?' do
  content_type :json
  document_by_id('Renderobjects', params[:id])
end

# find documents by name
get '/Renderobjects/name/:name/?' do
  content_type :json
  documents_by_name('Renderobjects', params[:name])
end

#   -----------------------------------------------------------------------------------------
#                                      post methods 
#   Current issues:
# => Make this work. Make a post method.
#   -----------------------------------------------------------------------------------------

# insert a new document from the request parameters, then return the full document
#example: http://localhost:9393/Renderobjects/new/?title=thing&url=http://stackoverflow.com/questions/1805761/check-if-url-is-valid-ruby&render_type=test

post '/Renderobjects/new/?' do
  content_type :json
  new_id = settings.mongo_db['Renderobjects'].insert params #if params
  document_by_id('Renderobjects', new_id)
end


#   -----------------------------------------------------------------------------------------
#                                         helpers 
#   -----------------------------------------------------------------------------------------
helpers do
	# a helper method to turn a string ID representation into a BSON::ObjectId
	def object_id val
		BSON::ObjectId.from_string(val)
	end

	def document_by_id (collection, id)
		id = object_id(id) if String === id
		settings.mongo_db[collection].
		  find_one(:_id => id).to_json
	end

	def documents_by_name (collection, name)
		settings.mongo_db[collection].find(:name => name).to_a.to_json
	end

end





