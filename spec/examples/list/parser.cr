class ListParser < Syntaks::Parser
  rule(:root, Array(String), _os >> "(" >> _os & item_list & ")") { |v| v[3] }
  rule(:item_list, Array(String), item >> ~item_list_tail) do |v|
    if tail = v[1]
      [v[0]] + tail
    else
      [v[0]]
    end
  end

  rule(:item_list_tail, Array(String), {"," & _os & item >> _os}) do |list|
    list.map(&.[2])
  end

  rule(:item, String, id >> _os) do |t|
    t[0]
  end

  rule(:id, String, /[_a-z][_a-z0-9]*/) { |r| r.content }

  ignored(:_os, /\s*/)
end
