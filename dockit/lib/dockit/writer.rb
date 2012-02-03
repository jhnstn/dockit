

require 'prawn'
module Dockit
  module Writer

    class Pdf


      def initialize(data)

        @@data = data
        @export_to = './export/test.pdf'
        if not Dir.exists?('./export') then Dir.mkdir('./export') end


      end

      def generate
               Prawn::Document.generate @export_to , :page_size => "LETTER" do

                  text "#{@@data} "
                  string ="page <page> of <total>"
                  options =  {
                      :at => [bounds.right - 150, 0] ,
                      :width => 150 ,
                      :align => :right ,
                      :start_count_at => 1
                  }
                  number_pages string , options
               end
      end

    end

    class Formatter




      def initialize(wiki)
        @wiki = wiki
        @last_level = 0

        @transcribe = {
            "#" => '1'  ,
            "##" => '1.1' ,
            "###" => '1.1.1',
            "####" => '1.1.1.a'

        }

        @level_format = ["1" , "1.1" , "1.1.1" , "1.1.1.a"]
        @increment = [0 ,0 , 0, 0]

        @spc = Prawn::Text::NBSP
        @tab = Prawn::Text::NBSP * 4

      end


      def toc

        toc = ""


        @wiki.toc.each do |key , value |
            label = value.gsub(/[\[\]]/,"").split('|').first
            toc <<   "#{@tab}" * (key.count ".")  << "#{key}  #{label}" << "\n"
         end
           toc
      end


      def transcribe

        transcribed = " "
        tabs = ""
        last_level = 0
        if File.readable?(@file) then
          data =   IO.readlines(@file)
          data.each do  |line|
           line.strip!

           level  = get_level line

           if level > 0 then
             # puts @increment.inspect

              if last_level > level then @increment.fill(0,level) end

              tabs = @tab * (level - 1)
              index = format_level  level
              line =  index << "\s" << line.sub(/[#]*/,'')


              last_level = level
           end
          # if line.last(1) != "\n" then
           #  line << "\n"
           #end
           transcribed << tabs << line << "\n"

          end
        else
          puts "Can not open file : #{@file}"
        end

        return transcribed
      end

      private

      def update_increment(level)


      end

      def get_level(line)
        if line.empty? then return 0  end
        split_index = line.index( /[^#]/)
      end

      def format_level(level)
         lvl_format = @level_format[level - 1]
         lvl_inc = @increment[level - 1] += 1


         level_str  = @increment.join('.').gsub(/\.0/,'')

         return level_str

         lvl_pos = lvl_format.split(".")
         if lvl_pos.empty? then lvl_pos = [lvl_format] end

         lvl_pos[-1] = Integer(lvl_pos.last) * lvl_inc

         lvl_pos.join(".")




      end
    end


  end
end


module LastN
  def last(n)
    self[-n,n]
  end
end
class String
  include LastN
end