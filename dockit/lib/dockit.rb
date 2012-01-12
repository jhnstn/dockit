

module Dockit

  class Merge

    def initialize(path , struct)
      @path = path || "."
      @struct = struct || "_Sidebar.md"
      @toc = {}

    end


    def merge

    end


    def toc
       doc_struct = "#{@path}/#{@struct}"

      if File.readable?(doc_struct) then

        data = IO.readlines( doc_struct)

        last_line = -1
        data.each do | line |
             line_index = line.to_first_int

               @toc[line_index] = line.strip!

        end



      end
      return @toc
    end



  end




end


class  String

    def to_first_int
        line_num = ""
          self.each_char do | char |
            break if "." == char
            line_num << char
          end
        return Integer(line_num)
    end
end