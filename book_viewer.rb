require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubi"
require "pry"

before do
  @toc = File.readlines("./data/toc.txt")
  @title = "The Adventure of Sherlock Holmes"
end

helpers do
  def in_paragraphs(chapter_number)
    chapter_content(chapter_number)
        .split("\n\n")
        .map
        .with_index do |paragraph, i|
      "<br><p id=paragraph#{i}>#{paragraph}</p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end

  def chapter_name(chapter_number)
    @toc[chapter_number - 1]
  end

  def chapter_content(chapter_number)
    File.read("./data/chp#{chapter_number}.txt")
  end

  def each_chapter
    (1..@toc.size).each do |chapter_number|
      chapter_name = chapter_name(chapter_number)
      chapter_content = chapter_content(chapter_number)

      yield chapter_name, chapter_number, chapter_content
    end
  end

  def matching_chapters(query)
    result = []

    each_chapter do |chapter_name, chapter_number, chapter_content|

      matching_paragraphs = {}

      chapter_content
        .split("\n\n")
        .each_with_index do |paragraph, index|
          matching_paragraphs[index] = paragraph if paragraph.include?(query)
        end

      if chapter_content.include? query
        result
          .append({ chapter_name: chapter_name, chapter_number:
          chapter_number, chapter_content: matching_paragraphs })
      end
    end

    result
  end

end

not_found do
  redirect "/"
end

get "/" do
  erb :home
end

get "/chapters/:chapter_number" do
  chapter_number = params[:chapter_number].to_i
  chapter_name = chapter_name(chapter_number)
  redirect "/" unless (1..@toc.size).include?(chapter_number)

  erb :chapter, locals: { chapter_number: chapter_number, chapter_name: chapter_name }
end

get "/search" do
    erb :search
end