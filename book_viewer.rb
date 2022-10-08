require 'tilt/erubis'
require 'sinatra'
require 'sinatra/reloader' if development?

before do
  @contents = File.readlines('data/toc.txt')
end

helpers do
  def in_paragraphs(chapter_content)
    chapter_content.split("\n\n").map.with_index do |para, idx|
      "<p id=#{idx}>" << para << "</p>"
    end.join
  end

  def para_array(chapter_content)
    chapter_content.split("\n\n").map.with_index do |para, idx|
      "<p id=#{idx}>" << para << "</p>"
    end
  end

  def highlight_match(content, query)
    # gsub shapter content, replacing query with query surrounded by strong tags
    content.gsub(query, "<strong>#{query}</strong>")
  end
end

get '/' do
  @title = 'The Adventures of Sherlock Holmes'

  erb :home
end

get '/chapters/:number' do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]

  redirect "/" unless (1..@contents.size).cover? number

  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get '/search' do
  @total_text = (1..@contents.size).each_with_object([]) do |number, arr|
    arr << File.read("data/chp#{number}.txt")
  end

  @chapter_results = []
  @total_text.each_with_index do |chapter, idx|
    @chapter_results << idx if chapter.match?(params[:query].to_s)
  end

  @para_matches = []


  erb :search
end

not_found do
  redirect "/"
end
