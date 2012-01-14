
require 'git'
require 'fileutils'
module Dockit



  class Wiki

    attr :merged_file

    def initialize(repo)
      @repo = repo
      @struct =  "Home.md"
      @local_path = '../.remote_wiki'

      @toc = {}
      @doc_struct = "#{@local_path}/#{@struct}"
      @merged_file

    end

    def fetch
      if Dir.exists?(@local_path) then
        g = Git.open(@local_path)
        g.reset_hard
        g.fetch
        g.pull
      else
          Git.clone(@repo,@local_path)
      end




    end

    def join

          if File.exists? "#{@local_path}/merged.md" then
            @merged_file =   "#{@local_path}/merged.md"
            return IO.read "#{@local_path}/merged.md"
          end

          if File.readable?(@doc_struct) then
            merged = ""
            data = IO.readlines(@doc_struct)

            data.each do |line|
                line_index = line.to_first_int
                if(line_index > 0) then
                  clean_line =  line.sub(/#{line_index}./,"").strip!
                  if clean_line.match(/\[\[/) then
                    link = clean_line.gsub(/[\[\]]/,"\s").split('|')
                    if  !link.last.nil? then
                      #file_name = link.last.split(/\]\]/).first.sub(/\s/,"-")  << ".md"
                      file_name = link.last.strip.gsub(/\s/,"-")  << ".md"
                      merged << "\n" << IO.read("#{@local_path}/#{file_name}")


                    end
                  end
                end
            end
            @merged_file = "#{@local_path}/merged.md"
              File.open("#{@local_path}/merged.md", 'w') {|f| f.write(merged) }
            return merged

          end

    end



  end

  class Merge

    def initialize
      @path =  '../.remote_wiki'
      @struct =  "Home.md"
      @toc = {}
      @doc_struct = "#{@path}/#{@struct}"


    end



    def merge

      if File.readable?(@doc_struct) then
        merged = ""
        data = IO.readlines(@doc_struct)

        data.each do |line|
            line_index = line.to_first_int
            if(line_index > 0) then
              clean_line =  line.sub(/#{line_index}./,"").strip!
              if clean_line.match(/\[\[/) then
                link = clean_line.split('|')
                link.inspect
                if  !link.last.nil? then
                  file_name = link.last.split(/\]\]/).first.sub(/\s/,"-")  << ".md"
                  merged << "\n" << IO.read("#{@path}/#{file_name}")


                end
              end
            end
        end
          File.open("#{@path}/merged.md", 'w') {|f| f.write(merged) }
          return merged
      end

    end


    def toc
       doc_struct = "#{@path}/#{@struct}"

      if File.readable?(doc_struct) then

        data = IO.readlines( doc_struct)

        last_level = 1
        data.each_with_index do | line , index |
             line_index = line.to_first_int

             if(line_index > 0) then
                clean_line =  line.sub(/#{line_index}./,"").strip!
                level = self.get_level(line)
                @toc[index] = clean_line
                if 1 == level then
                  puts clean_line
                elsif level > last_level then
                  @toc[]
                end
               last_level = level
             end

        end



      end
      return @toc
    end


    def get_level(line)
      level = 0
      line.each_char do | char |
        if " " ==  char then
          level += 1
        else
          break
        end

      end

      return  ((level  / 4.0).ceil) + 1
    end



  end




end






class  String


    def to_first_int

        line_num = ""
          self.each_char do | char |
            break if "." == char  || "\n" == char
            line_num << char
          end
         line_num.strip!

         return  line_num.to_i
    end
end