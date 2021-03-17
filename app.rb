#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
end

before do 
	init_db 
end

configure do 
		init_db
		#если не существет то создаест таблицу if not exists
		@db.execute 'create table if not exists Posts 
		(
			id integer primary key autoincrement,
			created_date date,
			content text
		)'

		@db.execute 'create table if not exists Comments 
		(
			id integer primary key autoincrement,
			created_date date,
			content text,
			id_post integer
		)'
end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index
end

get '/new' do
	erb :new
end

post '/new' do
	@content = params[:content]
	if @content.size == 0 
		@error = 'Введите текст поста'
		return erb :new	
	end
	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [@content]

	redirect '/'
end

get '/post/:id_post' do
	@id_post = params[:id_post]
	@results_post = @db.execute 'select * from Posts where posts.id = ?', [@id_post]
	@results_comments = @db.execute 'select comments.id as comments_id , comments.created_date as comments_created_date, 
									comments.content as comments_content, Comments.id_post as Comments_id_post  from Posts 
							left join Comments on Comments.id_post = Posts.id
							where posts.id = ?', [@id_post]
	@row = @results_post[0]
	erb :post
end

post '/post/:id_post' do 
	@id_post = params[:id_post]
	@content = params[:content]
	if @content.size == 0 
		@error = 'Введите текст комментария'
		return erb " "	
	end
		@db.execute 'insert into Comments (content, id_post, created_date) values (?, ?, datetime())', [@content, @id_post]
redirect "/post/#{@id_post}"
end