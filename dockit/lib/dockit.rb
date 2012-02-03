
require 'git'
require 'fileutils'
module Dockit



  class Wiki

    attr :merged_file
    attr :toc

    def initialize(repo)
      @repo = repo
      @struct =  "_Sidebar.md"
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

    def cleanup
      if Dir.exists? @local_path then FileUtils.rm_rf @local_path end
    end

    def flatten (path="")
         # puts "path : " << "#{@local_path}#{path}"
           if File.directory? "#{@local_path}#{path}"

             Dir.foreach "#{@local_path}#{path}" do  |entry|


               if "." == entry[0]  then next end
               unless  File.directory? "#{@local_path}#{path}/#{entry}"

                 unless "" == path
                 # puts "moving file : " << entry
                  FileUtils.mv("#{@local_path}#{path}/#{entry}" , "#{@local_path}/#{entry}")
                 end
               else

                 self.flatten("#{path}/#{entry}")
               end

             end
           end


    end

    def join
           puts "JOIN"

           #puts test.pwd
          if File.exists? "#{@local_path}/merged.md" then
            @merged_file =   "#{@local_path}/merged.md"
            return IO.read "#{@local_path}/merged.md"
          end

          if File.readable?(@doc_struct) then
            merged = IO.read(@doc_struct)   << "\n"
            data = IO.readlines(@doc_struct)

            data.each do |line|
                line_index = line.to_first_int
                if(line_index > 0) then
                  clean_line =  line.sub(/#{line_index}./,"").strip!
                 # puts "Clean Line : " << clean_line
                  if clean_line.match(/\[\[/) then
                    link = clean_line.gsub(/[\[\]]/,"\s").split('|')
                    #puts "Link : " << link.to_s
                    if  !link.last.nil? then
                      #file_name = link.last.split(/\]\]/).first.sub(/\s/,"-")  << ".md"
                      file_name = link.last.strip.gsub(/\s/,"-")  << ".md"
                     # puts "file name : " << "#{@local_path}/#{file_name}   exists: "     <<  (File.exists? "#{@local_path}/#{file_name}").to_s
                      #and !File.readable? "#{@local_path}/#{file_name}"
                      if File.exists? "#{@local_path}/#{file_name}"  then
                        puts "Merging " << file_name
                        merged << "\n\n\n" << IO.read("#{@local_path}/#{file_name}").gsub(/\t/,'    ')
                      end


                    end
                  end
                end
            end
            @merged_file = "#{@local_path}/merged.md"
              File.open("#{@local_path}/merged.md", 'w') {|f| f.write(merged) }
            return merged

          end

    end




    def build_toc
      if File.readable?(@doc_struct) then
            merged = IO.read(@doc_struct)   << "\n"
            data = IO.readlines(@doc_struct)
            levels = [0]
            curr_level = 0
            data.each_with_index do |line, index|
                line_index = line.to_first_int
                #line = line.gsub(/\t/,"\s\s\s\s")
                level = line=~ /\d/
                unless level.nil? or level > 3
                  d_level = level - curr_level


                  if d_level > 0
                    levels.push 1
                  elsif  d_level.zero?
                     levels.push levels.pop+1
                  else
                    levels.pop  d_level * -1
                    levels.push levels.pop+1
                  end



                  @toc["#{levels.join('.')}"] = line.sub(/[\d\.\n\t]+/,"").strip
                 # puts levels.inspect
                  curr_level = level
                 end
            end


       #@toc.each do |key , value |
       #  label = value.gsub(/[\[\]]/,"").split('|').first
       #  puts  "\s\s" * (key.count ".")  << "#{key}  #{label}"
       #end
      end
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